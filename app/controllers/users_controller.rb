class UsersController < ApplicationController
  require 'json'
  require "date"
  #edit,updateアクションが実行される前にlogged_in_userというメソッドを実行する
  #ログインしていないユーザはアクセスできないようにする
  before_action :logged_in_user , only: [:index, :edit , :update, :destroy , :following, :followers]
  before_action :correct_user   , only: [:edit , :update]
  before_action :admin_user     , only: :destroy

  #ページネーションを用いて10件ずつ取得している
  def index
    @users = User.all.page(params[:page]).per(10)
  end

  def show
    @user = User.find(params[:id])
    #ユーザに紐づいている投稿を6件分取得して返す
    @type = params[:type]
    @posts =  
      if @type == "1"
        @user.goods.created_at_desc.page(params[:page]).per(6)
      elsif @type == "2"
        @user.goods.created_at_asc.page(params[:page]).per(6)
      else
        @user.goods.good_desc.page(params[:page]).per(6)
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
      @user.send_activation_email
      flash[:info] = "登録されたメールアドレスに有効化メールを送信しました。送信されたメールからアカウントの有効化を行ってください"
      redirect_to "/users/#{@user.id}/1"
    else
      render 'new' , status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    #updateメソッドは既存のレコードに対してのみ使用できる
    if @user.update(user_params)
      #更新に成功した場合を扱う
      flash[:success] = "プロフィールを変更しました"
      redirect_to "/users/#{@user.id}/1"
    else
      render 'edit' , status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find(params[:id])
    user_name = user.name
    user.destroy
    flash[:success] = "#{user_name}さんを削除しました"
    redirect_to users_url, status: :see_other
  end

  def following
    @title = "フォロー"
    @user = User.find(params[:id])
    @users = @user.following.page(params[:pages]).per(10)
    render 'show_follow'
  end

  def followers
    @title = "フォロワー"
    @user = User.find(params[:id])
    @users = @user.followers.page(params[:pages]).per(10)
    render 'show_follow'
  end

  #ユーザのプロフィールを表示する
  def profile 
    @user = User.find(params[:id])
    #プロフィール設定が終わっている場合にのみ読書歴、好きなジャンル、おすすめtop3の情報をビューファイルに送信する
    if @user.profile_completed
      #読書歴を動的に変更するためにデータを整形している
      differences = (Date.today - Date.parse(@user.reading_history + "-01")).to_i 
      @year = differences / 365
      @month = (differences % 365) / 30
      @favorite_genre = @user.favorite_genre
      @top3 = @user.recommendation_books
    else
      @year = "0"
      @month = "0"
      @favorite_genre = "未設定"
      @top3 = {"top_1" => "未設定" , "top_2" => "未設定" , "top_3" => "未設定" }
    end
  end

  #ユーザのプロフィールを作成する
  def profile_new
    @user = User.find(params[:id])

    if !current_user?(@user)
      flash[:danger] = "この操作は行えません"
      redirect_to "/users/#{@user.id}/1"
    end
    
    if !session[:tmp_recommendation_books]
      session[:tmp_recommendation_books] = { "top_1" => "未設定", "top_2" => "未設定", "top_3" => "未設定" }
      @post = session[:tmp_recommendation_books]
    else
      @post = session[:tmp_recommendation_books]
    end
    @year_month = session[:year_month]
    @favorite_genre = session[:favorite_genre]
  end

  #プロフィールでおすすめの本を設定する
  def setting_top
    @user = User.find(params[:user_id])
    @id = params[:id]
    @posts = @user.goods.page(params[:page]).per(6)
  end

  def view_top
    user = current_user
    @post = user.goods.find(params[:id])
    @top_id = params[:top_id]
    #一時的に結果をセッションに加える
    session[:tmp_recommendation_books]["top_#{@top_id}"] = @post.id
    redirect_to "/users/profile_new/#{user.id}"
  end

  def view_top_edit
    user = current_user
    @post = user.goods.find(params[:id])
    @top_id = params[:top_id]
    #一時的に結果をセッションに加える
    session[:tmp_recommendation_books]["top_#{@top_id}"] = @post.id
    redirect_to "/users/profile_edit/#{user.id}"

  end

  #送信されたデータをプロフィールに保存してレコードを更新する
  def setting_profile
    user = current_user
    recommendation_books = { top_1: params[:top_1] , top_2: params[:top_2] , top_3: params[:top_3] }
    #データベースに保存するハッシュを作成する
    result = profile_params.merge(recommendation_books: recommendation_books)
    if user.update(result)
      flash[:success] = "プロフィールを作成しました!"
      user.update(profile_completed:  true)
    else
      flash[:danger] = "プロフィールを作成できませんでした"
    end


    #投稿内容を保存する一時セッションとして使用した情報をリセットする
    session[:year_month] = "" if session[:year_month]
    session[:favorite_genre] = "" if session[:favorite_genre]
    session[:tmp_recommendation_books] = { "top_1" => "未設定", "top_2" => "未設定", "top_3" => "未設定" }

    redirect_to "/users/profile/#{user.id}"
  end

  #読書開始年月と好きなジャンルが選択された際に一時セッションの保存するための処理
  #フロント側からfetch関数を用いてリクエストを送信するので何らかの戻り値を期待している
  def profile_tmp_save 
    year_month = params[:yearMonth]
    favorite_genre = params[:favoriteGenre]
    
    #ここで実際に一時セッションを作成して保存する処理を書く
    session[:year_month] = year_month
    session[:favorite_genre] = favorite_genre
    head :ok#戻り値としてHTTPステータスコードを返す
  end

  #プロフィール変更のためのフォームを表示する
  def profile_edit_new
    @user = User.find(params[:id])

    if !current_user?(@user)
      flash[:danger] = "この操作は行えません"
      redirect_to "/users/#{@user.id}/1"
    end
    
    if !session[:tmp_recommendation_books]
      session[:tmp_recommendation_books] = { "top_1" => "未設定", "top_2" => "未設定", "top_3" => "未設定" }
    else
      @post = session[:tmp_recommendation_books]
    end
    @year_month = session[:year_month]
    @favorite_genre = session[:favorite_genre]
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
    #データベースに保存するハッシュを作成する
    result = new_profile_params.merge( recommendation_books: new_recommendation_books )
    if user.update(result)
      flash[:success] = "プロフィールを変更しました!"
      user.update(profile_completed:  true)
    else
      flash[:danger] = "プロフィールを変更できませんでした"
    end

    #投稿内容を保存する一時セッションとして使用した情報をリセットする
    session[:year_month] = "" if session[:year_month]
    session[:favorite_genre] = "" if session[:favorite_genre]
    session[:tmp_recommendation_books] = { "top_1" => "未設定", "top_2" => "未設定", "top_3" => "未設定"}

    redirect_to "/users/profile/#{user.id}"
  end

  private 
    #このメソッドの戻り値は許可されたパラメータが含まれたハッシュ
    #管理者であるのかどうかを確認できるadminカラムを設置したがこれはストロングパラメータには含めてはいけない
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def profile_params
      params.require(:profile_info).permit(:reading_history, :favorite_genre)
    end

    #beforeフィルタ

    #正しいユーザかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    #管理者かどうか確認
    def admin_user
      redirect_to(root_url , status: :see_other) unless current_user.admin?
    end
end
