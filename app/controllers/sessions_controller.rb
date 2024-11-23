class SessionsController < ApplicationController
  def new
  end

  def create 
    #登録する際にメールアドレスはbefore_saveで小文字で保存していたので入力されたメールアドレスも小文字に直す
    user = User.find_by(email: params[:session][:email].downcase)
    #authenticateメソッドは成功するとそのレコードを返す
    #!!をつけると成功した際にtureに変換することができる
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        #reset_sessionの前に記述しないと遷移先URLを取得した後でもすべてリセットされてしまう
        forwarding_url = session[:forwarding_url]#これはフレンドリーフォワーディングを実装する為の記述
        reset_session #これはセッション固定攻撃への対策
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        log_in user   #ユーザのセッションを作成する
        flash[:success] = "ログインしました"
        redirect_to forwarding_url || "/users/#{user.id}/1"  #ログインしたユーザページに遷移する
        #ユーザログイン後にユーザ情報のページにリダイレクトする
      else
        message = "アカウントが有効化されていません。送信されたメールからアカウントの有効化を行ってください"
        flash[:warning] = message
        redirect_to new_user_path
      end
    else 
      "エラーメッセージを作成する"
      #renderはあたらしいリクエストを送信せずに画面の描画を行うのでflashメッセージが意図しない結果になる
      #flash.nowにすることで現在のリクエストから次にリクエストが送信されるまでが表示の対象になる
      flash.now[:danger] = "Invalid email/password combination"
      render 'new' , status: :unprocessable_entity
    end

  end

  def destroy
    #logoutメソッドでは@current_userをnilに設定するので今回の実装では先にforgetを実行するべき
    forget(current_user)
    log_out
    flash[:success] = "ログアウトしました"
    redirect_to login_path, status: :see_other  
  end
end
