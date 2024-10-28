class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit , :update]
  before_action :valid_user, only: [:edit , :update]
  before_action :check_expiration, only: [:edit, :update]
  def new
  end

  def create 
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "入力されたメールアドレスにパスワード再設定用のメールを送信しました"
      redirect_to login_path
    else 
      flash.now[:info] = "メールアドレスに紐づいたアカウントが見つかりませんでした"
      render 'new' , status: :unprocessable_entity
    end
  end

  def edit

  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "パスワードが空です")
      render 'edit' , status: :unprocessable_entity
    elsif @user.update(user_params)
      reset_session
      log_in @user
      #パスワードの変更が完了すればreset_digestは必要なくなるので削除する。これは安全のためにも働く
      @user.update(:reset_digest, nil)
      flash[:success] = "パスワードが変更されました!"
      redirect_to @user
    else
      render 'edit' , status: :unprocessable_entity
    end
  end

  private 
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
    def get_user 
      @user = User.find_by(email: params[:email])
    end

    #正しいユーザかどうか確認する
    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    #トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "有効期限切れです"
        redirect_to new_password_reset_url
      end
    end
end
