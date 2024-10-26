class AccountActivationsController < ApplicationController
    def edit
        if user && !user.activated? && user.authenticated?(:activation ,params[:id])
            user.activate
            log_in user
            flash[:success] = "アカウントを有効化しました!"
            redirect_to user
        else
            flash[:danger] = "アカウントを有効化できませんでした"
            redirect_to new_user_path
        end
    end
end
