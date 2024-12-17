class User < ApplicationRecord
    has_many :shelfs , dependent: :destroy
    has_many :goods , dependent: :destroy
    has_one :episode , dependent: :destroy

    #ここで設定している外部キーはフォローしているユーザを取得するためのもの
    has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id" , dependent: :destroy
    has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id" , dependent: :destroy

    has_many :following , through: :active_relationships, source: :followed
    has_many :followers,  through: :passive_relationships, source: :follower

    has_many :likes, dependent: :destroy
    has_many :what_goods , through: :likes , source: :good
    # has_many :followeds , through: :active_relationshipsのようにすればactive_relationshipsのfollowed_idに一致する
    #記憶トークンを保持する仮想の属性を定義する,このように実装するのは生の記憶トークンはデータベースに保存したくないから
    attr_accessor :remember_token , :activation_token, :reset_token
    before_save :downcase_email
    before_create :create_activation_digest
    validates :name , presence: true , length: { maximum: 50 }

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true , length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX}
    
    has_secure_password
    #allow_nil: trueを設定したことでカラムに入力された値がnilだった場合にバリデーションをスキップする。
    #このようにするのはhas_secure_passwordでもnilに対してのバリデーションが適用されるから
    validates :password , presence: true , length: { minimum: 6} , allow_nil: true

    validates :reading_history , presence: true
    validates :favorite_genre , presence: true
    validates :recommendation_books , presence: true
    validates :birthday, presence: true
    validates :occupations , presence: true
    validates :gender , presence: true
    validates :episode , presence: true , length: { maximum: 1000 }#保存できる最大の文字数を1000文字に設定する

    #エピソードのソートにおいて年齢のソートをスコープとして切り出す
    scope :birthday_desc , -> { order(birthday: :desc) }
    scope :birthday_asc , -> { order(birthday: :asc) }

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

    #ユーザのステータスフィードを返す
    def feed
        #ユーザがフォローしているユーザのidを配列にして返すfollowing_idsではデータベースからメモリに値が読み込まれて配列が作成される
        #→これでは効率が悪い。必要なのはIN句の中に比較するためのidの集まりを持ってくるだけでいい
        #includesを用いることでeager loadingをできる
        #これを行うのはN+1クエリ問題を解決するため
        following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
        Good.where("user_id IN (#{following_ids}) OR user_id = :user_id" , user_id: id).includes(:user)
    end

    #パスワード再設定の属性を設定する
    def create_reset_digest
        self.reset_token = User.new_token
        update_attribute(:reset_digest, User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
    end

    #パスワード再設定のメールを送信する
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
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

    #パスワード再設定の期限が切れている場合はtrueを返す
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end

    #ユーザをフォローする
    #ユーザがフォローしているユーザをまとめた配列のようなものの末尾に対してユーザを加える
    def follow(other_user)
        following << other_user unless self == other_user
    end

    #ユーザをフォーロー解除する
    #ユーザがフォローしているユーザをまとめた配列の中からユーザを削除する
    def unfollow(other_user)
        following.delete(other_user)
    end

    #現在のユーザがほかのユーザをフォローしていればtrueを返す
    def following?(other_user)
        following.include?(other_user)
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
