class User < ApplicationRecord
    #記憶トークンを保持する仮想の属性を定義する,このように実装するのは生の記憶トークンはデータベースに保存したくないから
    attr_accessor :remember_token , :activation_token
    before_save :downcase_email
    before_save :create_activation_digest
    validates :name , presence: true , length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true , length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX} , uniqueness: true
    has_secure_password
    #allow_nil: trueを設定したことでカラムに入力された値がnilだった場合にバリデーションをスキップする。
    #このようにするのはhas_secure_passwordでもnilに対してのバリデーションが適用されるから
    validates :password , presence: true , length: { minimum: 6} , allow_nil: true

    #渡された文字列のハッシュを返す
    def self.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                      BCrypt::Engine.cost
        BCrypt::Password.create(string , cost: cost)
    end

    #ランダムなトークンを返す
    def self.new_token
        #ランダムな22文字の文字列を生成する。一文字の種類が64種類あることからBase64と呼ばれている
        SecureRandom.urlsafe_base64
    end

    #永続的セッションのためにユーザをデータベースに記憶する
    def remember
        self.remember_token = User.new_token
        #update_attributeはバリデーションの適用ができない
        #今回はユーザのパスワードやパスワード確認にアクセスできない
        update_attribute(:remember_digest , User.digest(remember_token))
        remember_digest
    end

    #セッションハイジャック防止のためにセッショントークンを返す
    #この記憶ダイジェストを再利用しているのは単に利便性のため
    def session_token
        remember_digest || remember
    end

    #渡されたトークンがダイジェストと一致したらtrueを返す
    #渡されるattributeがremember, activationのどちらでも処理が同じなので１つにまとめている
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    #ユーザのログイン情報を破棄する
    def forget
        update_attribute(:remember_digest , nil)
    end

    #アカウントを有効化する
    def activate
        update_attribute(:activated, true)
        update_attribute(:activated_at, Time.zone.now)
    end

    #有効化用のメールを送信する
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    private 
      #メールアドレスを術tえ小文字にする
      def downcase_email
        self.email = email.downcase
      end

      #有効化トークンとダイジェストを作成および代入する
      def create_activation_digest
        self.activation_token = User.new_token
        self.activation_digest = User.digest(activation_token)
      end
end
