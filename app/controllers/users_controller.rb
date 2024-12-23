#このような記述をしているのでusersControllerクラスはApplicationControllerクラスを継承していることになる
class UsersController < ApplicationController
  require 'json'
  require "date"

  #ログインしていないユーザはアクセスできないようにする
  before_action :logged_in_user , only: [:index, :edit , :update, :destroy , :following, :profile_new, :setting_top, :view_top , :setting_profile , :profile_tmp_save , :profile_edit_new , :profile_edit , :profile_edit]
  before_action :correct_user   , only: [:edit , :update]
  before_action :admin_user     , only: :destroy
  before_action :get_user       , only: [:show,:turbo_stream_show,:turbo_stream_my_goods,:edit,:update,:destroy,
                                         :following,:followers,:profile,:profile_new,:setting_top,:profile_edit_new]

  #ページネーションを用いて10件ずつ取得している
  def index
    #ビュー側でアクションで設定していないインスタンス変数に対してアクセスしたときはnilが帰る。これはRubyの言語仕様
    @users = User.all.page(params[:page]).per(10)
  end

  def show
    #ユーザに紐づいている投稿を6件分取得して返す 
    @goods = Good.get_posts(@user.id , params[:type] , params[:page] , 6)
  end

  #ここではTurboStreamを用いて各ユーザの投稿一覧の画面のリロードを行うための処理を書く
  def turbo_stream_show 
    @posts = Good.get_posts(@user.id , params[:type] , params[:page] , 6)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to "/users/#{@user.id}/#{params[:type]}" }
    end
  end

  #いいね一覧でTurboStreamを用いて１部分だけリロードする
  def turbo_stream_my_goods
    @posts = @user.get_posts_my_goods(params[:type] , params[:page] , 6)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to "/posts/my_goods/#{@user.id}" }
    end

  end

  def new
    @user = User.new
  end

  def create
    #ストロングパラメータを用いて許可されたパラメータのみを含んだハッシュを受けてる
    @user = User.new(user_params)
    #会員登録が成功するとそのままログインする
    if @user.save
        forwarding_url = session[:forwarding_url]#これはフレンドリーフォワーディングを実装する為の記述
        reset_session #これはセッション固定攻撃への対策
        log_in @user   #ユーザのセッションを作成する
        flash[:success] = "アカウントを作成、ログインしました！"
        redirect_to forwarding_url || "/users/#{@user.id}/1"
    else
      render 'new' , status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    #updateメソッドは既存のレコードに対してのみ使用できる
    if @user.update(user_params)
      #更新に成功した場合を扱う
      flash[:success] = "アカウント情報を変更しました"
      redirect_to "/users/#{@user.id}/1"
    else
      render 'edit' , status: :unprocessable_entity
    end
  end

  def destroy
    user_name = @user.name
    @user.destroy
    flash[:success] = "#{user_name}さんを削除しました"
    redirect_to users_url, status: :see_other
  end

  def following
    @title = "フォロー"
    @users = @user.following.page(params[:pages]).per(10)
    render 'show_follow'
  end

  def followers
    @title = "フォロワー"
    @users = @user.followers.page(params[:pages]).per(10)
    render 'show_follow'
  end

  #ユーザのプロフィールを表示する
  def profile 
    #プロフィール設定が終わっている場合にのみ読書歴、好きなジャンル、おすすめtop3の情報をビューファイルに送信する
    if @user.profile_completed
      #読書歴を動的に変更するためにデータを整形している
      @differences = @user.reading_history != "未設定" ? (Date.today - Date.parse(@user.reading_history + "-01")).to_i : 0
      @year = @differences / 365
      @month = @differences % 365 / 30
      @age = @user.birthday != "未設定" ? (Date.today - Date.parse(@user.birthday)).to_i / 365 : "0"
      @top3 = @user.recommendation_books
    end
  end
  #ユーザのプロフィールを作成する
  def profile_new
    if !current_user?(@user)
      flash[:danger] = "この操作は行えません"
      redirect_to "/users/#{@user.id}/1"
    end
    
    #tmp_reccomendation_booksというキーをセッションが持たない時にはセッションを新たに作成する
    #session.key?メソッドは引数に指定されたキーを持つセッションが存在するかどうかを調べる
    if !session.key?(:tmp_recommendation_books)
      session[:tmp_recommendation_books] = { "top_1" => "未設定", "top_2" => "未設定", "top_3" => "未設定" }
      @post = session[:tmp_recommendation_books]
    else
      @post = session[:tmp_recommendation_books]
    end
    @year_month = session[:year_month] || ""
    @favorite_genre = session[:favorite_genre] || ""
    @birthday = session[:birthday] || ""
    @gender = session[:gender] != "" ? session[:gender] : ""
    @occupations = session[:occupations] || ""

    #プロフィール作成を開始してセッションに/users/profile_new/:idがなかったらURLを取得して格納する
    session[:profile_new_url] ||= request.fullpath
  end

  #プロフィールでおすすめの本を設定する
  def setting_top
    @id = params[:post_id]
    @posts = @user.goods.page(params[:page]).per(6)#何も取得するものがなかった際にはからの配列[]が返る
  end

  def view_top
    user = current_user
    @post = user.goods.find(params[:id])
    @top_id = params[:top_id]
    #一時的に結果をセッションに加える
    session[:tmp_recommendation_books]["top_#{@top_id}"] = @post.id

    #セッション情報からリダイレクト先を決める
    if session[:profile_new_url] 
      redirect_to session[:profile_new_url]
    elsif session[:profile_edit_url]
      redirect_to session[:profile_edit_url]
    else
      flash[:danger] = "不正なアクセスです"
      redirect_to "/users/profile/#{user.id}"
    end
  end

  #送信されたデータをプロフィールに保存してレコードを更新する
  def setting_profile
    user = current_user
    recommendation_books = { top_1: params[:top_1] , top_2: params[:top_2] , top_3: params[:top_3] }
    #データベースに保存するハッシュを作成する
    result = profile_params.merge(recommendation_books: recommendation_books)

    #エピソードが入力されたときのみエピソードの作成日時を更新する
    #Time.currentはRailsで提供する機能でアプリケーションで設定されたタイムゾーンをもとに時刻を設定する
    #Time.nowはRubyで提供される機能でサーバーのタイムゾーンに依存する時刻を設定する

    if user.update(result)
      flash[:success] = "プロフィールを作成しました!"
      user.update(profile_completed:  true)
    else
      flash[:danger] = "プロフィールを作成できませんでした"
    end


    #投稿内容を保存する一時セッションとして使用した情報をリセットする
    session.delete(:year_month) if session[:year_month]
    session.delete(:favorite_genre) if session[:favorite_genre]
    session.delete(:birthday) if session[:birthday]
    session.delete(:gender) if session[:gender]
    session.delete(:occupations) if session[:occupations]
    session[:tmp_recommendation_books] = { "top_1" => "未設定", "top_2" => "未設定", "top_3" => "未設定" }
    session.delete(:profile_new_url)

    redirect_to "/users/profile/#{user.id}"
  end

  #読書開始年月と好きなジャンルが選択された際に一時セッションの保存するための処理
  #フロント側からfetch関数を用いてリクエストを送信するので何らかの戻り値を期待している
  def profile_tmp_save 
    #ここで実際に一時セッションを作成して保存する処理を書く
    session[:year_month] = params[:yearMonth]
    session[:favorite_genre] = params[:favoriteGenre]
    session[:birthday] = params[:birthday]
    session[:gender] = params[:gender]
    session[:occupations] = params[:occupations]
    # session[:episode]に対して入力された内容を保存するには容量が足りなくなることがあるので現状では使用しない
    head :ok#戻り値としてHTTPステータスコードを返す
  end
  
  #プロフィール変更のためのフォームを表示する
  def profile_edit_new
    if !current_user?(@user)
      flash[:danger] = "この操作は行えません"
      redirect_to "/users/#{@user.id}/1"
    end
    
    if !session.key?(:tmp_recommendation_books)
      session[:tmp_recommendation_books] = { "top_1" => "未設定", "top_2" => "未設定", "top_3" => "未設定" }
      @post = session[:tmp_recommendation_books]  
    else
      @post = session[:tmp_recommendation_books] 
    end
    @year_month = session[:year_month] || ""
    @favorite_genre = session[:favorite_genre] || ""
    @birthday = session[:birthday] || ""
    @genre = session[:genre] || ""
    @gender = session[:gender] || ""
    @occupations  = session[:occupations] || ""
    #プロフィール変更を開始してセッションに/users/profile_edit/:idがなかったらURLを取得して格納する
    session[:profile_edit_url] ||= request.fullpath
  end

  #送信されたデータを実際にデータベースに保存する
  def profile_edit
    user = current_user
    #本のおすすめ３つの投稿の中で変更されたものだけ新しいハッシュにまとめる
    recommendation_books = { "top_1" => params[:top_1] , "top_2" => params[:top_2] , "top_3" => params[:top_3] }
    new_recommendation_books = {}#データの整形を行ったハッシュを入れる
    recommendation_books.each do |key , value|
      new_recommendation_books[key] = value ==  "未設定" ? user.recommendation_books[key] : value
    end

    #ストロングパラメータに関しても上と同様の操作を行う
    new_profile_params = profile_params.select { |key , value| value != "" }
    #エピソードが再設定されない限り更新日時は更新しない
    if new_profile_params.has_key?(:episode)
      #更新された内容にepisodeが含まれていれば更新するハッシュに対してエピソードの更新時間を含める
      #mergeメソッドはハッシュの結合を行った新しいハッシュをか返すので元のハッシュに対して変更を加えることはできない
      new_profile_params = new_profile_params.merge(episode_updated_time: Time.current)
    end
  
    #データベースに保存するハッシュを作成する
    result = new_profile_params.merge( recommendation_books: new_recommendation_books )
    puts result
    if user.update(result)
      flash[:success] = "プロフィールを変更しました!"
      user.update(profile_completed:  true)
    else
      flash[:danger] = "プロフィールを変更できませんでした"
    end

    #投稿内容を保存する一時セッションとして使用した情報をリセットする
    session.delete(:year_month) if session[:year_month]
    session.delete(:favorite_genre) if session[:favorite_genre]
    session.delete(:birthday) if session[:birthday]
    session.delete(:gender) if session[:gender]
    session.delete(:occupations) if session[:occupations]
    session[:tmp_recommendation_books] = { "top_1" => "未設定", "top_2" => "未設定", "top_3" => "未設定" }
    session.delete(:profile_edit_url)

    redirect_to "/users/profile/#{user.id}"
  end

  #privateメソッドを使用して定義されているので以下のメソッドはこのクラス定義の中でしか参照できない
  private 
    #このメソッドの戻り値は許可されたパラメータが含まれたハッシュ
    #管理者であるのかどうかを確認できるadminカラムを設置したがこれはストロングパラメータには含めてはいけない
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def profile_params
      params.require(:profile_info).permit(:reading_history, :favorite_genre, :occupations , :gender, :birthday)
    end

    #beforeフィルタ

    #正しいユーザかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    #@userに対して指定されたUserオブジェクトを格納する
    def get_user
      @user = User.find(params[:id])
    end

    #管理者かどうか確認
    def admin_user
      redirect_to(root_url , status: :see_other) unless current_user.admin?
    end
end
