class ShelfsController < ApplicationController
    #ログインしていないユーザにはアクセスを認めない
    before_action :logged_in_user , only: [:create , :show , :update , :turbo_stream_show]

    def new 
        @book_info = params[:bookInfo].to_s
    end

    #マイ本棚は自分しか閲覧できないようにする
    #ログインを必須とするのでcurrent_userは常に存在することになる
    #このエンドポイントに対してリクエストが送信された際には未読の一覧を表示する
    def show
        @type = params[:type].to_i
        #ifの中で取得する結果がnilでないことを保証するためにボッチ演算子を使用する
        @my_shelf = 
          if @type == 1
            current_user.shelfs.where(unread_flag: 1)
          else
            current_user.shelfs.where(unread_flag: 0)
          end&.page(params[:page]).per(6)
    end

    def create 
        @book_info = params[:bookInfo].to_s

        #この下で実際にレコードを追加する処理を書く
        item = current_user.shelfs.build(book_info: @book_info)
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
        type = @my_shelf.unread_flag
        if @my_shelf.unread_flag == 1
            @my_shelf.update_attribute(:unread_flag , 0)
            flash[:success] = "読了に変更しました!"
            redirect_to "/shelfs/#{type}"
        end
    end

    #マイ本棚から本を削除するための処理
    def destroy
      shelf = Shelf.find(params[:id])
      type = shelf.unread_flag#リダイレクトに用いるためのフラグ
      shelf.destroy
      flash[:success] = "マイ本棚から削除しました"
      
      #リダイレクト用のパスを取得する
      #request.refererを使用する際にはnilだった時のエラーハンドリングが必要
      #DELETEリクエストが送信された後のリダイレクトはブラウザによってはDELETEリクエストが使用されることがあるのでこれを強制的にGETに変換するためのもの
      #303ステータスコードはリソースを取得するために指定されたURLに対してGETリクエストを送信することを指示するためのもの

      #ここではリクエストがTurboStreamに変換される可能性があるのであらかじめリダイレクト先をTurboStream用に設定しておく
      redirect_to "/shelfs/turbo_stream_show/#{type}", status: :see_other
    end
end
