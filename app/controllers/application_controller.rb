class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  #ログインに関するヘルパーメソッドを全てのコントローラーで使用できるようにするにはここでmoduleをincludeすればいい
  include SessionsHelper#これはモジュールのミックスインを使用している

  #ログイン済みユーザかどうかを確認
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください"
      redirect_to login_url , status: :see_other
    end
  end

  def valid_user(user)
    if !current_user?(user)
      flash[:danger] = "このページにはアクセスできません"
      redirect_to "/users/#{user.id}/1"
    end
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
end
