class AccountActivationsController < ApplicationController
    def edit
        if !user.authenticated?(:activation, params[:id])
            flash[:success] = "有効化トークンとダイジェストが一致しません"
        elsif user.activated? 
            flash[:success] = "すでに有効化されています"
        elsif !user
            flash[:success] = "ユーザが存在しません"
        end
        user = User.find_by(email: params[:email])
        if user && !user.activated? && user.authenticated?(:activation ,params[:id])
            user.activate
            log_in user
            # flash[:success] = "アカウントを有効化しました!"
            redirect_to user
        else
            # flash[:danger] = "アカウントを有効化できませんでした"
            redirect_to new_user_path
        end
    end
end
