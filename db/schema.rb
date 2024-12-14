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

ActiveRecord::Schema[7.2].define(version: 2024_12_12_130526) do
  create_table "episodes", force: :cascade do |t|
    t.string "reading_history", null: false
    t.string "title", null: false
    t.string "trigger", limit: 1000
    t.string "about_trigger", null: false
    t.string "about_changing", null: false
    t.string "changing", limit: 1000
    t.datetime "episode_update_time"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "episode_complated", default: 0
    t.index ["user_id"], name: "index_episodes_on_user_id"
  end

  create_table "goods", force: :cascade do |t|
    t.json "book_data"
    t.integer "good_count", default: 0
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "post_name"
    t.string "genre"
    t.string "readability"
    t.string "convenience"
    t.string "recommendation"
    t.integer "shelf_id", null: false
    t.integer "user_id", null: false
    t.index ["created_at"], name: "index_goods_on_created_at"
    t.index ["created_at"], name: "index_goods_on_user_id_and_created_at"
    t.index ["good_count"], name: "index_goods_on_good_count"
    t.index ["shelf_id"], name: "index_goods_on_shelf_id"
    t.index ["user_id"], name: "index_goods_on_user_id"
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

  create_table "shelves", force: :cascade do |t|
    t.json "book_info"
    t.integer "unread_flag", default: 1
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_post", default: 0
    t.index ["user_id"], name: "index_shelves_on_user_id"
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
    t.boolean "activated", default: false
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
  end

  add_foreign_key "episodes", "users"
  add_foreign_key "goods", "shelves"
  add_foreign_key "goods", "users"
  add_foreign_key "likes", "goods"
  add_foreign_key "likes", "users"
  add_foreign_key "shelves", "users"
end
