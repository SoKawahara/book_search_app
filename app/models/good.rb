class Good < ApplicationRecord
  belongs_to :user

  #投稿をいいねしたユーザとの関連付けを行う
  has_many :likes , dependent: :destroy
  has_many :who_goods , through: :likes , source: :user

  #スコープを作成して発行したクエリの結果を取得する順番を指定する
  #orderメソッドを使用することで指定したカラムの順番でソートすることができる
  scope :created_at_desc, -> { order(created_at: :desc) }
  scope :created_at_asc , -> { order(created_at: :asc) }
  scope :good_desc , -> { order(good_count: :desc) }

  #以下ではモデルに対してバリデーションを行う
  validates :book_data , presence: true
  validates :good_count, presence: true
  validates :content , presence: true
  validates :genre , presence: true
  validates :readability, presence: true
  validates :convenience, presence: true
  validates :recommendation, presence: true

end
