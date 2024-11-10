class RelationshipsController < ApplicationController
    before_action :logged_in_user

    def create
        @user = User.find(params[:followed_id])
        current_user.follow(@user)
        respond_to do |format|
            format.html { redirect_to "/users/#{@user.id}/1" }
            format.turbo_stream#turbo_stream用のリクエストが送信される
        end
    end

    def destroy
        #ここで送られてくるidとはリレーションのidのこと。つまりこれには１対のフォロー、フォロワーの関係が入っている
        #その中からfollwoed,つまりフォローされている側のユーザーを取り出す
        @user = Relationship.find(params[:id]).followed
        current_user.unfollow(@user)
        respond_to do |format|
            format.html { redirect_to "/users/#{@user.id}/i", status: :see_other }
            format.turbo_stream#turbo_stream用のリクエストが送信される
        end
    end
end
