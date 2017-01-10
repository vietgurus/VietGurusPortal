# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170110041734) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "images", force: :cascade do |t|
    t.string   "path"
    t.string   "temp_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "status"
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "group"
    t.string   "cat_name"
    t.string   "title"
    t.string   "content"
    t.integer  "status",     default: 0
    t.string   "image_url"
    t.string   "up"
    t.string   "down"
    t.string   "creator_id"
    t.string   "result"
    t.integer  "number"
    t.integer  "type"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "password"
    t.string   "password_digest"
    t.string   "email"
    t.integer  "role"
    t.string   "avatar"
    t.string   "image_id"
    t.datetime "last_login_time"
    t.string   "image_url"
  end

end
