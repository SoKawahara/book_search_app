class EpisodesController < ApplicationController
    before_action :logged_in_user , only: [:new , :edit , :update]
    #ここではエピソードを作成するためのフォームを表示する
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

    private 
      def episode_params
        params.require(:episode_info).permit(:reading_history, :title, :about_trigger, :trigger , :about_changing , :changing)
      end
end

