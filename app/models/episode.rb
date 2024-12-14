class Episode < ApplicationRecord
  belongs_to :user

  validates :reading_history , presence: true 
  validates :title , presence: true 
  validates :about_trigger , presence: true 
  validates :about_changing , presence: true 
  validates :trigger , length: { maximum: 1000 }
  validates :changing , length: { maximum: 1000 }
  validates :episode_complated , numericality: { only_integer: true, in: 0..1 }

end
