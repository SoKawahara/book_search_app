class ShelfsController < ApplicationController
    #ログインしていないユーザにはアクセスを認めない
    before_action :logged_in_user , only: [:create , :show , :update , :turbo_stream_show]
    before_action :get_book_info  , only: [:new , :create]
    before_action :get_current_user , only: [:show , :create , :destroy]

    def new
      #このアクションの中で必要な処理はすべてbefore_actionで完結する
    end

    #マイ本棚は自分しか閲覧できないようにする
    #ログインを必須とするのでcurrent_userは常に存在することになる
    #このエンドポイントに対してリクエストが送信された際には未読の一覧を表示する
    def show
      @type = params[:type].to_i#これは現在選択されているのが「未読」「読了」どちらなのかを判別するためのフラグ
      @my_shelf = @user.get_my_shelfs(@type , params[:page] , 6)
    end

    def create 
      #この下で実際にレコードを追加する処理を書く
      item = @user.shelfs.build(book_info: @book_info)
      if item.save
        head :ok
      else
        head :bad_request
      end
      #処理が成功した場合のみ202というレスポンスを送信する
    end

    #ここでは未読の状態でチェックボタンが押された際に読了に変更を行う
    def update
        @my_shelf = Shelf.find(params[:shelf_id])
        change_unread_flag(@my_shelf)#ここで「未読」、「読了」の状態に応じてunread_flagの変更を行う
    end

    #マイ本棚から本を削除するための処理
    def destroy
      shelf = Shelf.find(params[:id])
      type = shelf.unread_flag#リダイレクトに用いるためのフラグ

      #GoodオブジェクトからShelfオブジェクトに対してshelf_idという外部キーで参照を行っているので先にShelfを削除すると外部キー制約に反する
      #よってShelfを参照しているGoodを先に削除する
      post = Good.find_by(shelf_id: shelf.id)

      if post 
        #ここでは削除する本がプロフィールに使用されていた場合にそれも削除しないといけない
        reco_books = @user.recommendation_books#これは現在のおすすめの本の情報が入っている
        reco_books.each do |k , v|
          if post.id == v.to_i 
            reco_books[k] = "未設定"
          end
        end
        @user.save if @user.changed?#もしrecommendation_booksに対して何らかの変更が加えられていたらそれを保存する
        post.destroy#ここで削除する対象の本の投稿を削除する
      end

      shelf.destroy
      flash[:success] = "マイ本棚から削除しました"

      redirect_to "/shelfs/turbo_stream_show/#{type}", status: :see_other
      
      
      #リダイレクト用のパスを取得する
      #request.refererを使用する際にはnilだった時のエラーハンドリングが必要
      #DELETEリクエストが送信された後のリダイレクトはブラウザによってはDELETEリクエストが使用されることがあるのでこれを強制的にGETに変換するためのもの
      #303ステータスコードはリソースを取得するために指定されたURLに対してGETリクエストを送信することを指示するためのもの

      #ここではリクエストがTurboStreamに変換される可能性があるのであらかじめリダイレクト先をTurboStream用に設定しておく
    end

    private 
      #ここではやり取りされる本の情報を取得する
      def get_book_info
        @book_info = params[:bookInfo].to_s
      end

      #このメソッドではボタンを押された際の本の状態に応じて状態を変更する処理を行う
      def change_unread_flag(my_shelf)
        type = my_shelf.unread_flag
        if type == 1
          @my_shelf.update_attribute(:unread_flag , 0)
          flash[:success] = "読了に変更しました!"
          redirect_to "/shelfs/#{type}"
        else
          @my_shelf.update_attribute(:unread_flag , 1)
          flash[:success] = "未読に変更しました!"
          redirect_to "/shelfs/#{type}"
        end
      end
end
