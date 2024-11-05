class PostsController < ApplicationController
    before_action :logged_in_user , only: [:new , :create, :good_counter]
    before_action :current_user ,    only: [:destroy]
    #ここに対して本の情報とセットでPOSTメソッドが送信されてくる
    def new
        #画面が再レンダリングされた際に@bookInfoがないことでエラーが発生するのを防ぐ
        @bookInfo = params[:bookInfo]
        render 'new' , locals: {book_info: @bookInfo}
    end

    def create
        @good = current_user.goods.build(info_params.merge("book_data" => params[:book_data]))
        if @good.save 
            flash[:success] = "投稿を作成しました"
            redirect_to "/users/#{current_user.id}"
        else
            flash[:danger] = "投稿を作成できませんでした"
            redirect_to "/searches/top"
        end

    end

    def edit
        user = current_user
        if user && @user_post = user.goods.find(params[:id])
            @user = user
            @user_post
        else
            flash[:danger] = "投稿が見つかりません"
            redirect_to user
        end
    end

    def update
        user = current_user
        if user && post = user.goods.find(params[:id])
            post.update(info_params)
            flash[:success] = "変更が適用されました"
            redirect_to user
        else
            flash[:danger] = "変更を適用できませんでした"
            redirect_to user
        end

    end

    #この投稿を削除するボタンを押された際に実際に投稿を削除する
    def destroy
        @user = current_user
        if @user && (post = @user.goods.find(params[:id]))
            post.destroy
            flash[:success] = "投稿を削除しました!"
            redirect_to @user , status: :see_other
        else
            flash[:danger] = "投稿を削除できませんでした"
            redirect_to @user , status: :see_other
        end



    end

    #いいねボタンが押されたらいいね数を更新
    def good_counter
        @user = current_user
        #送信された投稿のIDがユーザのものと紐づいていて、存在したらいいね数のカウントアップを行う
        if post = @user.goods.find(params[:id])
            post.good_count += 1 
            post.update_attribute(:good_count , post.good_count)
            flash[:success] = "いいねしました!!!"
            redirect_to @user
        else 
            flash[:danger] = "いいねできませんでした"
            redirect_to @user
        end

    end

    private
      def info_params
        params.require(:info).permit(:post_name, :content)
      end
end
