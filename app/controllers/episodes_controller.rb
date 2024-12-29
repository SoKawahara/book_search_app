class EpisodesController < ApplicationController
    require 'uri'
    require 'date'
    before_action :logged_in_user , only: [:new , :edit , :update]
    before_action :get_current_user , only: [:new , :create , :edit , :update]
    before_action :get_user , only: [:show]
    #ここではエピソードを作成するためのフォームを表示する

    #ここではユーザのepisode一覧を表示する
    #一覧を閲覧するだけならログインは必要としない
    def index
      #includesメソッドを用いてN+1クエリ問題を解消している
      #eager loadingで取得したuserはepisode.userで取得できる
      @episodes = Episode.get_episodes(params[:page] , 10)
    end

    #ここではエピソードに対して絞込検索を行う処理を実装する
    #画面の描画にはTurboStreamを使用して１部分のみの変更を加える
    def turbo_stream_index
        #取得したソートの条件からorderメソッドに格納する条件文字列を作成する
        order_condition = 
          if episode_sort_params["order"] == "作成日時"
            episode_sort_params["sort"] == "昇順" ? "episode_created_at ASC" : "episode_created_at DESC"
          elsif episode_sort_params["order"] == "読書歴"
            episode_sort_params["sort"] == "昇順" ? "reading_history DESC" : "reading_history ASC"
          else
            episode_sort_params["sort"] == "昇順" ? "birthday DESC" : "birthday ASC"
          end

        #ここではデータベースに格納してある誕生日から年齢を求めるためのSQL文を作成している
        age_sql = if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
            "EXTRACT(YEAR FROM age(DATE #{Date.today}, CAST(birthday AS DATE)))"
          else # SQLite3
            "(strftime('%Y', 'now') - strftime('%Y', birthday)) - (strftime('%m-%d', 'now') < strftime('%m-%d', birthday))"
          end

        #SQLクエリを発行した結果を取得する
        #絞り込みを行ったUserに対してEpisodeを結合している
        #get_filterd_userはUserクラスのクラスメソッド
        @users = User.get_filtered_users(episode_sort_params["gender"] , episode_sort_params["lower_age"].to_i , 
                                         age_sql , episode_sort_params["upper_age"].to_i , order_condition)
        #並べ替えの基準に何が指定されているのか
        @target =  episode_sort_params["order"]
    end

    def new
      @episode = @user.build_episode
    end

    def create 
        #エピソードの内容として送信された項目に対して、作成日時、エピソード登録完了のフラグを追加する
        @episode = @user.build_episode(episode_params.merge("episode_update_time" => Time.current , 
                                                            "episode_complated"  => 1))
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

      @redirect_path = request.referer
    end

    #ここではエピソードの編集画面を作成する
    def edit 
        @episode = current_user.episode
    end

    #ここではエピソードの変更内容を反映させる
    def update
        @episode = @user.episode
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

