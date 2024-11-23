class PostsController < ApplicationController
    before_action :logged_in_user , only: [:new , :create, :edit, :update , :good_counter , :feed]

    require "uri"
    require "date"
    #ここに対して本の情報とセットでPOSTメソッドが送信されてくる
    def new
        #画面が再レンダリングされた際に@bookInfoがないことでエラーが発生するのを防ぐ
        @bookInfo = params[:bookInfo]
        render 'new' , locals: {book_info: @bookInfo}
    end

    def create
        user = current_user
        #画像のURLが正規のものではない時エラー用の画像を指定する
        book_data = eval(params[:book_data])
        new_book_data = {}
        begin
            uri = URI.parse(book_data["imageLink"])
            @good = user.goods.build(info_params.merge("book_data" => params[:book_data]))
        rescue URI::InvalidURIError => e
            book_data["imageLink"] = "error.jpg"
            new_book_data = book_data.to_s
            @good = user.goods.build(info_params.merge("book_data" => new_book_data))
        end
    

        if @good.save 
            flash[:success] = "投稿を作成しました"
            redirect_to "/users/#{current_user.id}/1"
        else
            flash[:danger] = "投稿を作成できませんでした"
            redirect_to "/searches"
        end

    end

    def edit
        @user = current_user
        if @user_post = @user.goods.find(params[:id])
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
    #投稿を削除する際に削除する投稿がプロフィールに登録されているモノだったらプロフィールからも削除する
    def destroy
        @user = current_user
        if @user && (post = @user.goods.find(params[:id])) && valid_user(@user)
            #ユーザがプロフィールに登録している投稿の中に削除する投稿も含まれていればそれを変更する
            recommendation_books = (@user.recommendation_books)
            recommendation_books.each do |key , value|
                if post.id.to_s == value
                    recommendation_books[key] = "未設定"
                    @user.update(recommendation_books: recommendation_books)
                end
            end
            post.destroy
            flash[:success] = "投稿を削除しました!"

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
            #Turbo Streamを用いてリクエストを送信した際に現在のブラウザに表示されているURLからページネーションのためのクエリの値を取得するために一時セッションを作成する
            #page = 2をたたいた後になぞにpage = 1というリクエストに上書きされている
            session.delete(:original_url_my_goods) if session[:original_url_my_goods]

            page = request.query_parameters["page"]
            session[:original_url_my_goods] = page

            puts "---------------------------------------"
            puts page
            puts "---------------------------------------"

            @user = User.find(params[:id])
            #goods.user_idとしているのはambiguous columnエラーに対処するために明示的に
            @posts = @user.what_goods.where("goods.user_id != ?" , current_user.id).page(page).per(9)
        end
    end

    #いいね一覧において絞込検索が行われた際にこの部分でTurboStream用のリクエストを受ける
    def turbo_stream_my_goods
        @user = User.find(params[:id])
        @type = params[:type]

        page = session[:original_url_my_goods] || nil
        #params[:page]の部分が取得できなかった際には１ページ目を表示するという仕組みになっている
        @posts = 
          if @type== "1"
              @user.what_goods.where("goods.user_id != ?" , current_user.id).created_at_desc
          elsif @type == "2"
              @user.what_goods.where("goods.user_id != ?" , current_user.id).created_at_asc
          else
              @user.what_goods.where("goods.user_id != ?" , current_user.id).good_desc
          end&.page(page).per(9)

        respond_to do |format|
            format.html { redirect_to posts_my_goods_path(id: @user.id) }
            format.turbo_stream
        end
    end

    #いいねボタンが押されたら押された投稿のwho_goodsに対して押したユーザを格納する
    def good_counter
        @user = current_user
        #送信された投稿のIDがユーザのものと紐づいていて、存在したらいいね数のカウントアップを行う
        if post = Good.find(params[:id])
            #過去にこの投稿にいいねしたことがあるユーザは繰り返しいいねすることができないようにする
            if !(post.who_goods.include?(@user))
                good_count = post.good_count + 1
                post.update_attribute(:good_count  , good_count)
                post.who_goods << @user
                flash[:success] = "いいねしました!!!"
            else 
                flash[:danger] = "一つの投稿に複数回いいねすることはできません"
            end
            #リダイレクト先は遷移元ページのURLから動的に変更する
            redirect_path = request.referer
            if redirect_path.nil?
                redirect_to "/users/#{@user.id}/1"
            else
                redirect_to redirect_path
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
        @data = eval(post.book_data)
    end

    #ユーザがフォローしているユーザの投稿一覧を取得する
    def feed
        session.delete(:original_url_feed) if session[:original_url_feed]

        page = request.query_parameters["page"]
        session[:original_url_feed] = page

        puts "---------------------------------------"
        puts page
        puts "---------------------------------------"

        @type = params[:type]
        @posts = 
        if @type== "1"
            current_user.feed.created_at_desc
        elsif @type == "2"
            current_user.feed.created_at_asc
        else
            current_user.feed.good_desc
        end&.page(page).per(9)
    end

    #ここでは投稿一覧画面に対して表示方式が変更されてもTurbo Streamを用いてページの一部分だけをレンダリングする
    def turbo_stream_feed
        @type = params[:type]

        page = session[:original_url_feed] || nil
        @posts = 
        if @type== "1"
            current_user.feed.created_at_desc
        elsif @type == "2"
            current_user.feed.created_at_asc
        else
            current_user.feed.good_desc
        end&.page(page).per(9)

        respond_to do |format|
            format.turbo_stream
            format.html { redirect_to "/posts/feed/#{@type}" }
        end
    end

    #投稿一覧で「詳細を見る」ボタンが押された際に投稿を表示する
    def view_post
        #取得してきたuser_idとpost_idから対象となる投稿を取得
        @user_id = params[:user_id]
        @post_id = params[:post_id]
        user = User.find(@user_id)
        @post = user.goods.find(@post_id)
    end

    #絞り検索で取得してきた条件からユーザを取得する
    def sort_episodes
        #取得してきた性別の条件から発行するクエリを決定する
        gender_info = episode_params["gender"]
        @gender = gender_info != "" ? gender_info : nil 
        
        order_info = episode_params["order"]
        @order_info = order_info != "" ? order_info : "空白です"

        sort_info = episode_params["sort"]
        @sort_info = sort_info != "" ? sort_info : nil 

        #--------------------------------ここから下一部コピペ---------------------------------------------
        # 年齢計算用のSQLをDBMSに応じて設定,ここは完全にコピペ
        age_sql = if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
                    "EXTRACT(YEAR FROM age(DATE '#{today}', birthday))"
                  else # SQLite3
                    "(strftime('%Y', 'now') - strftime('%Y', birthday)) - (strftime('%m-%d', 'now') < strftime('%m-%d', birthday))"
                  end

        tmp = 
          if @gender != nil 
            User.where("gender == ? AND id != ?" , @gender , current_user)
          else
            User.where("id != ?" , current_user)
          end
        
        lower_age = episode_params["lower_age"].presence&.to_i
        upper_age = episode_params["upper_age"].presence&.to_i
        tmp = tmp.select("users.*, #{age_sql} AS age").where("#{age_sql} BETWEEN ? AND ?", lower_age, upper_age) if lower_age != nil && upper_age != nil

        @users = 
          case @order_info
          when "作成日時"
            if @sort_info == "昇順"
                tmp.order(episode_updated_time: :asc)
            else
                tmp.order(episode_updated_time: :desc)
            end
          #ここから下２つのカラムについて歴ではなく日付で登録してあるので歴で見たら長くなる
          when "読書歴"
            if @sort_info == "昇順"
                tmp.order(reading_history: :desc)
            else
                tmp.order(reading_history: :asc)
            end
          when "年齢"
            if @sort_info == "昇順"
                tmp.order(birthday: :desc)
            else
                tmp.order(birthday: :asc)
            end
          else
            tmp.order(episode_updated_time: :asc)
          end&.page(params[:page])&.per(10)
        # @users = User.where("gender == ? AND id != ?" , @gender , current_user.id).order(episode_updated_time: :asc).page(params[:page]).per(10)


        #取得してきた年齢の条件から発行するクエリを決める
        
        age = 
          if lower_age != nil && upper_age != nil
            (lower_age..upper_age)
          elsif lower_age != nil
            (lower_age..)
          elsif upper_age != nil
            (..upper_age)
          else#年齢に関する条件が何も指定されなかった時にはnilを指定する
            nil
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
