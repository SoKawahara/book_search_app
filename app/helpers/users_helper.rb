module UsersHelper
    #引数で与えられたユーザのGravatar画像のURLを返す
    def gravatar_for(user , options = { size: 500 })
        gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
        "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{options[:size]}"
    end
end
