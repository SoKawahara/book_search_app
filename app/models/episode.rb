class Episode < ApplicationRecord
  belongs_to :user

  validates :reading_history , presence: true 
  validates :title , presence: true 
  validates :about_trigger , presence: true 
  validates :about_changing , presence: true 
  validates :trigger , length: { maximum: 1000 }
  validates :changing , length: { maximum: 1000 }
  validates :episode_complated , numericality: { only_integer: true, in: 0..1 }

  #エピソードの並び替えの際に使用するORDER BYをスコープとして切り出しておく
  scope :created_at_desc, -> { order(created_at: :desc) }
  scope :created_at_asc , -> { order(created_at: :asc) }
  scope :reading_history_desc , -> { order(reading_history: :desc) }
  scope :reading_history_asc , -> { order(reading_history: :asc) }

  #エピソード一覧で表示するための全エピソードを取得するクラスメソッド
  #eager loadingを用いてN+1クエリ問題を解消している
  def self.get_episodes(page , num)
    self.where(episode_complated: 1).includes(:user).page(page).per(num)
  end
end
