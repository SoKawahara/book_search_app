# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

#メインのサンプルユーザを１人作成する
User.create!(name: "Example User" , email: "example@railstutorial.org" , password: "foobar" , password_confirmation: "foobar" , admin: true , activated: true , activated_at: Time.zone.now)

User.create!(name: "Sou Kawahara" , email: "kawaharasou0216@icloud.com" , password: "70ponkuN" , password_confirmation: "70ponkuN" , admin: false, activated: true , activated_at: Time.zone.now)
User.create!(name: "Izuku Midoriya" , email: "izukumidoriya@icloud.com" , password: "foobar" , password_confirmation: "foobar" , admin: false, activated: true , activated_at: Time.zone.now)
User.create!(name: "Tomura Shigaraki" , email: "tomurashigaraki@icloud.com" , password: "foobar" , password_confirmation: "foobar" , admin: false, activated: true , activated_at: Time.zone.now)
User.create!(name: "Shoyo Hinata" , email: "shoyohinata@icloud.com" , password: "foobar" , password_confirmation: "foobar" , admin: false, activated: true , activated_at: Time.zone.now)
User.create!(name: "Tobio Kageyama" , email: "tobiokageyama@icloud.com" , password: "foobar" , password_confirmation: "foobar" , admin: false, activated: true , activated_at: Time.zone.now)




