class EpisodesController < ApplicationController
    require 'uri'
    require 'date'
    before_action :logged_in_user , only: [:new , :edit , :update]
    #ここではエピソードを作成するためのフォームを表示する

    #ここではユーザのepisode一覧を表示する
    #一覧を閲覧するだけならログインは必要としない
    def index
      #includesメソッドを用いてN+1クエリ問題を解消している
      #eager loadingで取得したuserはepisode.userで取得できる
      @episodes = Episode.where(episode_complated: 1).includes(:user).page(params[:page]).per(10)
    end

    #ここではエピソードに対して絞込検索を行う処理を実装する
    #画面の描画にはTurboStreamを使用して１部分のみの変更を加える
    def turbo_stream_index
        #ここでは入力された値に対してSQL内で使用できるように値の整形を行う
        new_params = episode_sort_params.to_h.map do |k , v|
            if k == "lower_age" || k == "upper_age"
                [k ,v.to_i]
            else 
                [k , v]
            end
        end.to_h

        #取得したソートの条件からorderメソッドに格納する条件文字列を作成する
        order_condition = 
          if new_params["order"] == "作成日時"
            new_params["sort"] == "昇順" ? "episode_created_at ASC" : "episode_created_at DESC"
          elsif new_params["order"] == "読書歴"
            new_params["sort"] == "昇順" ? "reading_history DESC" : "reading_history ASC"
          else
            new_params["sort"] == "昇順" ? "birthday DESC" : "birthday ASC"
          end


        #ここではデータベースに格納してある誕生日から年齢を求めるためのSQLをDBMSごとに発行している
        age_sql = if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
            "EXTRACT(YEAR FROM age(DATE #{Date.today}, birthday))"
          else # SQLite3
            "(strftime('%Y', 'now') - strftime('%Y', birthday)) - (strftime('%m-%d', 'now') < strftime('%m-%d', birthday))"
          end

        #SQLクエリを発行した結果を取得する
        #絞り込みを行ったUserに対してEpisodeを結合している
        @users = User.where("gender = ? and #{age_sql} between ? and ?" , new_params["gender"] , new_params["lower_age"] , new_params["upper_age"]).
                       joins(:episode).
                       select("episodes.title as title , episodes.created_at as episode_created_at , users.id as user_id , users.email as email , 
                               users.gender as gender , users.reading_history as reading_history , users.birthday as birthday,
                               users.id as user_id , users.name as name , users.email as email , users.gender as gender , 
                               users.birthday as birthday , users.reading_history as reading_history").
                       order(order_condition).includes(:episode)

        #並べ替えの基準に何が指定されているのか
        @target = new_params["order"]
    end

    def new
      @user = current_user#ログインしていないユーザはアクセスできないのでこれは保証される
      @episode = @user.build_episode
    end

    def create 
        @user = current_user#ログインしていないユーザからのアクセスはできないのでこれは保証される
        #ここから下ではフォームから送信され来た結果に対してエピソードの作成日時を記録する
        result = episode_params.merge("episode_update_time" => Time.current).merge("episode_complated" => 1)
        #resultを用いてepisodep
        @episode = @user.build_episode(result)

        if @episode.save
            flash[:success] = "エピソードを作成しました!"
            redirect_to "/episodes/#{@user.id}"#作成に成功した場合にはエピソードページにリダイレクトする
        else
            #保存に失敗した際にはエピソードの登録用フォームを再び描画する
            #unproccessable_entityとはHTTPレスポンス422を表していいてRailsアプリではフォームのバリデーションエラーなどの際に使用される
            flash.now[:danger] = "エピソードの内容に誤りがあります。再度入力してください"
            render 'new' ,  status: :unprocessable_entity
        end
    end

    def show
      @user = User.find(params[:user_id])
      #もしもまだエピソードが作成されていない時にはエピソードの作成画面へ遷移させる
      #@episodeはまだレコードが作成されていない時にはnilが返る
      @episode = @user.episode

      #ここから下にはビューファイルで使用する要素を作成する
      if @episode
        reading_history = @episode.reading_history.to_s#これは読書を始めた年月を表す
        if reading_history[(5..5)] == "0"#1～9月の時は先頭の0を除いたものを送信する
            @reading_history = "#{reading_history[(0..3)]}年の#{reading_history[(6..6)]}月くらいからです!"
        else
            @reading_history = "#{reading_history[(0..3)]}年の#{reading_history[(5..6)]}月くらいからです!"
        end
        @reading_time = (Date.today - Date.parse(@episode.reading_history + "-01")).to_i#これは読書を始めた日からの現在までの日数を表している
      end

      #戻るボタンの送信先を設定する,request.refererを使用する際にはnilである可能性を考慮する必要がある
      #request.refererではURLのフルパスが返ってくる

      @redirect_path = request.referer
    end

    #ここではエピソードの編集画面を作成する
    def edit 
        @user = current_user
        @episode = current_user.episode
    end

    #ここではエピソードの変更内容を反映させる
    def update
        @episode = current_user.episode
        #new_episode_paramsは変更があった要素だけを入れたハッシュ
        new_episode_params = episode_params.select do |key , value|
            value != "" ? true : false
        end

        if @episode.update(new_episode_params)
            flash[:success] = "エピソードを変更しました!"
            redirect_to "/episodes/#{current_user.id}"
        else
            flash.now[:danger] = "エピソードの変更に誤りがあります。再度入力してください"
            render 'edit' , status: :unprocessable_entity
        end
    end

    #ここでは絞り込み条件で指定された条件に基づいて絞り込んだ結果を反映する
    def sort_episodes

    end

    private 
      #これはエピソードを作成する際に使用するストロングパラメータ
      def episode_params
        params.require(:episode_info).permit(:reading_history, :title, :about_trigger, :trigger , :about_changing , :changing)
      end

      #これはエピソードの絞り込みを行う際のストロングパラメータ
      def episode_sort_params
        params.require(:sort_info).permit(:lower_age , :upper_age , :gender , :order , :sort)
      end
end

