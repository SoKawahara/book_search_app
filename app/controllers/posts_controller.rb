class PostsController < ApplicationController
    before_action :logged_in_user , only: [:new , :create, :good_counter, :view_about, :feed, :view_post]
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
            redirect_to "/users/#{current_user.id}/1"
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
            redirect_to "users/#{user.id}/1"
        end
    end

    def update
        user = current_user
        if user && post = user.goods.find(params[:id])
            #送信された値が空白であった場合には現在設定されている値を入れることで特定の要素だけ変更可能にする
            #変更が加えられた部分のみを入れたハッシュを作成してそれをupdateメソッドに渡している
            #ハッシュに対してselectメソッドを使用すると条件を満たす要素だけを新たなハッシュとして作成する
            new_params = info_params.select do |key , value|
                value != ""
            end
            post.update(new_params)
            flash[:success] = "変更が適用されました"
            redirect_to "/users/#{user.id}/1"
        else
            flash[:danger] = "変更を適用できませんでした"
            redirect_to "/users/#{user.id}/1"
        end

    end

    #この投稿を削除するボタンを押された際に実際に投稿を削除する
    def destroy
        @user = current_user
        if @user && (post = @user.goods.find(params[:id]))
            post.destroy
            flash[:success] = "投稿を削除しました!"
            redirect_to "/users/#{@user.id}/1" , status: :see_other
        else
            flash[:danger] = "投稿を削除できませんでした"
            redirect_to "/users/#{@user.id}/1" , status: :see_other
        end
    end

    #いいねボタンが押されたらいいね数を更新
    def good_counter
        @user = User.find(params[:user_id])
        #送信された投稿のIDがユーザのものと紐づいていて、存在したらいいね数のカウントアップを行う
        if post = @user.goods.find(params[:id])
            post.good_count += 1 
            post.update_attribute(:good_count , post.good_count)
            flash[:success] = "いいねしました!!!"
            #リダイレクト先は現在のページから動的に変更する
            if request.path =~ /\/posts\/good_counter\/\d+\/\d+/
                redirect_to "/users/#{@user.id}/1"
            else
                redirect_to "/posts/feed/1"
            end
            
        else 
            flash[:danger] = "いいねできませんでした"
            redirect_to "/users/#{@user.id}/1"
        end
    end

    #この本の詳細ページへが押された場合に実行される処理
    def view_about
        @user = User.find(params[:user_id])
        post = @user.goods.find(params[:id])
        @id = post.user_id
        @data = eval(post.book_data)
    end

    #ユーザがフォローしているユーザの投稿一覧を取得する
    def feed
        @type = params[:type]
        @posts = 
        if @type== "1"
            current_user.feed.created_at_desc.page(params[:page]).per(10)
        elsif @type == "2"
            current_user.feed.created_at_asc.page(params[:page]).per(10)
        else
            current_user.feed.good_desc.page(params[:page]).per(10)
        end
    end

    #投稿一覧で「詳細を見る」ボタンが押された際に投稿を表示する
    def view_post
        #取得してきたuser_idとpost_idから対象となる投稿を取得
        @user_id = params[:user_id]
        @post_id = params[:post_id]
        @post = User.find_by(@user_id).goods.find(@post_id)
    end

    private
      def info_params
        params.require(:info).permit(:post_name, :content, :genre, :readability, :convenience, :recommendation)
      end
end
