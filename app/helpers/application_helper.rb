module ApplicationHelper

    def full_title(title = "")
        base_title = "Search Books App"
        if title.empty?
            base_title
        else
            "#{title} | #{base_title}"
        end
    end

    #紹介ページ以外で表示する
    def now_pages?
        #controller_name,action_nameはコントローラーやビューファイルの中で使用される組込み変数
        #現在表示されているページでのコントローラーとアクションを取得するための変数
        (controller_name == "static_pages" && action_name == "home") ? true : false
    end
end
