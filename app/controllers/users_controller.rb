class UsersController < ApplicationController
  #edit,updateアクションが実行される前にlogged_in_userというメソッドを実行する
  #ログインしていないユーザはアクセスできないようにする
  before_action :logged_in_user , only: [:index, :edit , :update, :destroy]
  before_action :correct_user   , only: [:edit , :update]
  before_action :admin_user     , only: :destroy

  #ページネーションを用いて10件ずつ取得している
  def index
    @users = User.all.page(params[:page]).per(10)
  end

  def show
    @user = User.find(params[:id])
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
      redirect_to new_user_path
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
      redirect_to @user
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

  private 
    #このメソッドの戻り値は許可されたパラメータが含まれたハッシュ
    #管理者であるのかどうかを確認できるadminカラムを設置したがこれはストロングパラメータには含めてはいけない
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    #beforeフィルタ

    #ログイン済みユーザかどうかを確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください"
        redirect_to login_url , status: :see_other
      end
    end

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
