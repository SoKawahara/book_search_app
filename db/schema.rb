# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_11_16_014354) do
  create_table "goods", force: :cascade do |t|
    t.json "book_data"
    t.integer "good_count", default: 0
    t.integer "evaluation_count", default: 0
    t.text "content"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "post_name"
    t.text "good_users", default: "-1"
    t.string "genre"
    t.string "readability"
    t.string "convenience"
    t.string "recommendation"
    t.index ["user_id", "created_at"], name: "index_goods_on_user_id_and_created_at"
  end

  create_table "likes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "good_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["good_id"], name: "index_likes_on_good_id"
    t.index ["user_id", "good_id"], name: "index_likes_on_user_id_and_good_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "followed_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_relationships_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_relationships_on_follower_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "activation_digest"
    t.boolean "activated", default: true
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.string "reading_history", default: "0"
    t.string "favorite_genre", default: "未設定"
    t.json "recommendation_books", default: {"top_1"=>"未設定", "top_2"=>"未設定", "top_3"=>"未設定"}
    t.boolean "profile_completed", default: false
    t.string "birthday", default: "未設定"
    t.string "occupations", default: "未設定"
    t.string "gender", default: "未設定"
    t.text "episode", default: "未設定"
    t.datetime "episode_updated_time", default: "2024-11-15 05:24:39"
  end

  add_foreign_key "goods", "users"
  add_foreign_key "likes", "goods"
  add_foreign_key "likes", "users"
end
