module SessionsHelper
    #渡されたユーザでログインする
    def log_in(user)
        session[:user_id] = user.id
        #:user_idがセキュリティ的に危険なのでもう一つ保証するための値をsession内に入れておく
        #session_tokenにはremember_digestを用いる。bcryptを用いて暗号化された値は安全なので2つの用途に対しても使用できる
        session[:session_token] = user.session_token
    end

    #永続的セッションのためにユーザをデータベースに記憶する
    def remember(user)
        user.remember
        #２０年期限の暗号化されたユーザのidを保存する
        cookies.permanent.encrypted[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    #現在ログイン中のユーザを返す, ログインしているユーザがなかった場合にはnilが返る
    def current_user
        if (user_id = session[:user_id])
            user = User.find_by(id: user_id)
            if user && session[:session_token] == user.session_token
                @current_user = user
            end
        #復号化したユーザidを取得している
        elsif (user_id = cookies.encrypted[:user_id])
            user = User.find_by(id: user_id)
            if user && user.authenticated?(:remember, cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end

    #ユーザがログインしていればtrue,そのほかならfalseを返す
    def logged_in?
        !current_user.nil?
    end

    #永続的セッションを破棄する
    def forget(user)
        user.forget #データベースの中の:remember_digestカラムの値を削除する
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    #現在のユーザをログアウトする
    def log_out
        reset_session
        @current_user = nil
    end

    #渡されたユーザがカレントユーザであればtrueを返す
    def current_user?(user)
        user && user == current_user
    end

    #アクセスしようとしたURLを保存する
    def store_location
        #GETメソッドが送られた際にリクエスト先のURLを保存する
        session[:forwarding_url] = request.original_url if request.get?
    end
end
