class PostsController < ApplicationController
    before_action :logged_in_user , only: [:new , :create, :edit, :update , :turbo_stream_good_counter , :turbo_stream_good_remover , :feed]
    before_action :get_current_user , only: [:new , :create , :edit , :update , :destroy , :feed , :turbo_stream_good_remover , :turbo_stream_good_counter]
    require "uri"
    require "date"

    #こっちのnewアクションは読了ページから取得された
    def new
        @id = params[:id]
        @item = @user.shelfs.find_by(id: @id)
    end

    def create
        #画像のURLが正規のものではない時エラー用の画像を指定する
        book_data = eval(params[:book_data])
        id = params[:shelf_id]#これから感想を作成する本のマイ本棚でのIDを取得している

        #ストロングパラメータで取得してきたハッシュに対して本の情報と本棚に入れてある本のIDを付加してデータの登録を行う
        #本のデータに格納されている画像のURLを解析して、適切なものでない時例外を発生させてエラー用の画像を追加する
        begin
            URI.parse(book_data["imageLink"])
            @good = @user.goods.build(info_params.merge("book_data" => params[:book_data]).merge("shelf_id" => id))
        rescue URI::InvalidURIError => e
            book_data["imageLink"] = "error.jpg"
            @good = @user.goods.build(info_params.merge("book_data" => book_data.to_s).merge("shelf_id" => id))
        end
    

        if !@good.post_save(id).nil? 
            flash[:success] = "投稿を作成しました"
            redirect_to "/users/#{current_user.id}/1"
        else
            flash[:danger] = "投稿を作成できませんでした"
            redirect_to "/shelf/1"
        end

    end

    def edit
        @user_post = @user.get_my_post(params[:id])
    
        #万が一投稿が見つからなかった時(get_my_postの戻り値がnil)の時にはリダイレクトを行う
        if @user_post.nil?
            flash[:danger] = "投稿が見つかりません"
            redirect_to "users/#{user.id}/1"
        end
    end

    def update
        if @user && post = @user.get_my_post(params[:id])
            #送信された値が空白であった場合には現在設定されている値を入れることで特定の要素だけ変更可能にする
            #変更が加えられた部分のみを入れたハッシュを作成してそれをupdateメソッドに渡している
            #ハッシュに対してselectメソッドを使用すると条件を満たす要素だけを新たなハッシュとして作成する
            new_params = info_params.select do |key , value|
                value != ""
            end

            #変更が加えられた際にのみ更新を保存する
            post.update(new_params) if !new_params.empty?
            flash[:success] = "変更が適用されました"
            redirect_to "/users/#{@user.id}/1"
        else
            flash[:danger] = "変更を適用できませんでした"
            #HTTPステータスコード422とはリクエストの内容は正常だがフォームのバリデーションエラーなどで処理ができなかった際に指定される
            render 'edit' , status: :unprocessable_entity
        end

    end

    #この投稿を削除するボタンを押された際に実際に投稿を削除する
    #投稿を削除する際に削除する投稿がプロフィールに登録されているモノだったらプロフィールからも削除する
    def destroy
        if @user && (post = @user.get_my_post(params[:id])) && current_user?(@user)
            recommendation_books = @user.recommendation_books
            recommendation_books.each do |key , value|
                #これから削除する投稿のidがおすすめの中に含まれていた際にそれも併せて削除する
                if post.id.to_s == value
                    recommendation_books[key] = "未設定"
                end
            end
            #Userオブジェクトに対して変更が加えられていた場合のみUserモデルの更新を行う
            @user.update(recommendation_books: recommendation_books) if @user.changed?
        
            #shelf_idからもとになった本棚にある本を取得してその本棚から投稿が作成されていない状態に戻す
            Shelf.find(post.shelf_id).update_attribute(:created_post , 0)

            post.destroy#投稿を削除する
            flash[:success] = "投稿を削除しました!"

            #Turboを使用している際や一部のブラウザではGET,POST以外のメソッドでリクエストが送信された際にはリダイレクト先にも同じメソッドでリクエストを送信する可能性がある
            redirect_to "/users/#{@user.id}/1" , status: :see_other
        else
            flash[:danger] = "投稿を削除できませんでした"
            redirect_to "/users/#{@user.id}/1" , status: :see_other
        end
    end

    #ここでは自分がいいねした投稿一覧を表示する
    def my_goods
        if params[:id] == '0' || !logged_in?
            flash[:danger]= 'ログインしてください'
            redirect_to login_path
        else
            session.delete(:original_url_my_goods) if session[:original_url_my_goods]
            @posts = User.find(params[:id]).get_posts_my_goods(params[:type] , request.query_parameters["page"] , 9)
        end
    end

    #すでにいいねされた投稿のいいねを再び押すといいねが解除される
    def turbo_stream_good_remover
        if (@post = Good.find(params[:post_id])) && @post.who_goods.include?(@user)
            @post.update_attribute(:good_count , @post.good_count - 1)
            @post.who_goods.delete(@user)#いいね数を一つ減らしていいねしたユーザを格納する配列から削除する
        end
        #いいね数を更新した後にビューファイルに対していいね数を送信する
        @good_count = @post.who_goods.count
    end

    #いいねが押された際に画面遷移を行わずにいいねボタンだけいいねしたことが分かる画像に変更する
    #具体的にはTurboStreamを用いて非同期で画面遷移を行う
    def turbo_stream_good_counter
        if (@post = Good.find(params[:post_id])) && !(@post.who_goods.include?(@user))
            @post.update_attribute(:good_count , @post.good_count + 1)
            @post.who_goods << @user
        end
        #いいね数を更新した後にビューに対していいね数を送る,いいね数の更新が行われなくてもいいね数をビューに返す
        @good_count = @post.who_goods.count 
    end


    #この本の詳細ページへが押された場合に実行される処理
    def view_about
        @user = User.find(params[:user_id])
        @data = eval(@user.goods.find(params[:id]).book_data)
    end

    #ユーザがフォローしているユーザの投稿一覧を取得する
    def feed
        @posts = @user.get_feed_posts(params[:type] , request.query_parameters["page"] , 9)
    end

    #投稿一覧で「詳細を見る」ボタンが押された際に投稿を表示する
    def view_post
        #取得してきたuser_idとpost_idから対象となる投稿を取得
        @user_id = params[:user_id]
        @post_id = params[:post_id]
        @post = User.find_by(id: @user_id).goods.find(@post_id)

        #ここでリダイレクト先を変更する
        #URIライブラリを用いてrequest.refererからパス部分を取得する,エラーが発生した場合にはユーザページに遷移するようにする
        begin
            @redirect_path = URI.parse(request.referer).path
        rescue URI::InvalidURIError => e
            @redirect_path = "/users/#{@user_id}/1"
        end
    end

    private
      def episode_params
        params.require(:sort_info).permit(:upper_age , :lower_age , :gender , :order, :sort)
      end

      def info_params
        params.require(:info).permit(:post_name, :content, :genre, :readability, :convenience, :recommendation)
      end
end
