class Shelf < ApplicationRecord
  belongs_to :user


  validates :book_info , presence: true
  validates :unread_flag, presence: true , numericality: { only_integer: true, in: 0..1 }
  #only_integer: trueとすることで入力値を整数型に限定することができる
  #inを使用することで範囲オブジェクトを使用して値の範囲を限定することができる
end
