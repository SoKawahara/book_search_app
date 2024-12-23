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
  before_action :get_current_user   , only: [:view_top , :setting_profile , :profile_edit]

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
    preparation_for_profile(@user , "new")
  end

  #プロフィールでおすすめの本を設定する
  def setting_top
    @id = params[:post_id]
    @posts = @user.goods.page(params[:page]).per(6)#何も取得するものがなかった際にはからの配列[]が返る
  end

  def view_top
    @post = @user.goods.find(params[:id])
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
    recommendation_books = { top_1: params[:top_1] , top_2: params[:top_2] , top_3: params[:top_3] }

    if @user.update(profile_params.merge(recommendation_books: recommendation_books))
      flash[:success] = "プロフィールを作成しました!"
      @user.update(profile_completed:  true)
    else
      flash[:danger] = "プロフィールを作成できませんでした"
    end

    #投稿内容を保存する一時セッションとして使用した情報をリセットする
    init_sessions("new")
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
    preparation_for_profile(@user , "edit")
  end

  #送信されたデータを実際にデータベースに保存する
  def profile_edit
    #本のおすすめ３つの投稿の中で変更されたものだけ新しいハッシュにまとめる
    new_recommendation_books = { "top_1" => params[:top_1] , "top_2" => params[:top_2] , "top_3" => params[:top_3]}.
                                select { |value , key| value != "" ? true : false }

    #ストロングパラメータに関しても上と同様の操作を行う
    new_profile_params = profile_params.select { |key , value| value != "" }
    
    #データベースに保存するハッシュを作成する
    if @user.update(new_profile_params.merge(recommendation_books: new_recommendation_books))
      flash[:success] = "プロフィールを変更しました!"
      @user.update(profile_completed:  true)
    else
      flash[:danger] = "プロフィールを変更できませんでした"
    end

    #投稿内容を保存する一時セッションとして使用した情報をリセットする
    init_sessions("edit")
  end

  #privateメソッドを使用して定義されているので以下のメソッドはこのクラス定義の中でしか参照できない
  private
    #------------------------------------ストロングパラメータ------------------------------------------
    #このメソッドの戻り値は許可されたパラメータが含まれたハッシュ
    #管理者であるのかどうかを確認できるadminカラムを設置したがこれはストロングパラメータには含めてはいけない
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def profile_params
      params.require(:profile_info).permit(:reading_history, :favorite_genre, :occupations , :gender, :birthday)
    end
    
    #--------------------------------ストロングパラメータここまで---------------------------------------

    #---------------------------------------beforeフィルタ--------------------------------------------

    #正しいユーザかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    #@userに対して指定されたUserオブジェクトを格納する
    def get_user
      @user = User.find(params[:id])
    end

    #userに対して現在ログインしているユーザを格納する
    #この時インスタンス変数として設定するのはローカル変数とするとメソッドの外では参照できないから
    def get_current_user
      @user = current_user
    end

    #管理者かどうか確認
    def admin_user
      redirect_to(root_url , status: :see_other) unless current_user.admin?
    end

    #---------------------------------beforeフィルターここまで-------------------------------------------

    #ここではプロフィールを新規作成、編集する際にフォームを表示する際に必要なデータとその処理をひとまとめにする処理を書く
    #引数として新規作成なのか編集なのかを受け取る
    def preparation_for_profile(user, type)
      if !current_user?(user)
        flash[:danger] = "この操作は行えません"
        redirect_to "/users/#{user.id}/1"
      end
      
      #tmp_reccomendation_booksというキーをセッションが持たない時にはセッションを新たに作成する
      #このセッションには登録する予定のおすすめの本の情報が格納されている
      session[:tmp_recommendation_books] ||= { "top_1" => "未設定" , "top_2" => "未設定" , "top_3" => "未設定" }
  
      @post = session[:tmp_recommendation_books]
      @year_month = session[:year_month] || ""
      @favorite_genre = session[:favorite_genre] || ""
      @birthday = session[:birthday] || ""
      @gender = session[:gender] != "" ? session[:gender] : ""
      @genre = session[:genre] != "" ? session[:genre] : ""
      @occupations = session[:occupations] || ""
  
      #プロフィール作成を開始してセッションに/users/profile_new/:idがなかったらURLを取得して格納する
      session["profile_#{type}_url".to_sym] ||= request.fullpath
    end

    #プロフィールの作成画面で使用したsession情報を削除、初期化する
    def init_sessions(type)
      session.delete(:year_month) if session[:year_month]
      session.delete(:favorite_genre) if session[:favorite_genre]
      session.delete(:birthday) if session[:birthday]
      session.delete(:gender) if session[:gender]
      session.delete(:occupations) if session[:occupations]
      session[:tmp_recommendation_books] = { "top_1" => "未設定" , "top_2" => "未設定" , "top_3" => "未設定" }
      session.delete("profile_#{type}_url".to_sym) 

      redirect_to "/users/profile/#{@user.id}"
    end
end
