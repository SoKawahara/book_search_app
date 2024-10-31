class Good < ApplicationRecord
  belongs_to :user

  #デフォルトスコープを作成して、新しく作成した順にレコードを取得できるようにする
  scope :created_at_desc, -> { order(created_at: :desc) }
  scope :created_at_asc , -> { order(created_at: :asc) }
  scope :good_desc , -> { order(good_count: :desc) }

  #以下ではモデルに対してバリデーションを行う
  validates :book_data , presence: true
  validates :good_count, presence: true
  validates :evaluation_count , presence: true , length: { maximum: 5 }
  validates :content , presence: true

end
