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

ActiveRecord::Schema.define(version: 2020_05_23_092431) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "brochures", force: :cascade do |t|
    t.binary "content"
    t.binary "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "rotation"
  end

  create_table "broshejointables", force: :cascade do |t|
    t.integer "sheet_id"
    t.integer "brochure_id"
    t.integer "order_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cards", force: :cascade do |t|
    t.integer "card"
    t.string "position"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "player_id"
    t.string "game_id"
  end

  create_table "conshejointables", force: :cascade do |t|
    t.integer "contact_id", default: 0
    t.integer "sheet_id", default: 0
    t.integer "order_number", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "description_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.string "position", default: ""
    t.string "email_address", default: ""
    t.string "tel_number", default: ""
    t.string "mobile_number", default: ""
    t.string "url", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rotation", default: 0
    t.binary "image"
  end

  create_table "contacts_sheets", force: :cascade do |t|
    t.integer "sheet_id", default: 0
    t.integer "contact_id", default: 0
    t.integer "order_number", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "description_id"
  end

  create_table "cribgames", force: :cascade do |t|
    t.boolean "hasstarted"
    t.string "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "freezenewplayers"
    t.integer "whosecrib"
  end

  create_table "cribplayers", force: :cascade do |t|
    t.integer "number"
    t.string "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "lastplay"
    t.integer "score"
    t.string "name"
    t.string "game_id"
    t.datetime "redealrequest"
    t.datetime "resetrequest"
    t.boolean "ismobile"
  end

  create_table "descriptions", force: :cascade do |t|
    t.text "text"
    t.integer "contact_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "followings", force: :cascade do |t|
    t.integer "following_user_id"
    t.integer "monitored_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "usergroup_id"
  end

  create_table "locationgroups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locationlogs", force: :cascade do |t|
    t.decimal "latitude"
    t.decimal "longitude"
    t.integer "user_id"
  end

  create_table "logs", force: :cascade do |t|
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sheet_id"
  end

  create_table "positionlogs", force: :cascade do |t|
    t.decimal "latitude"
    t.decimal "longitude"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sheets", force: :cascade do |t|
    t.string "client_name", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "number", default: "000000"
    t.string "password"
  end

  create_table "shopvisits", force: :cascade do |t|
    t.string "user"
    t.datetime "visitdate"
    t.integer "visit_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "usergroups", force: :cascade do |t|
    t.string "name"
    t.boolean "bespoke"
    t.decimal "north"
    t.decimal "south"
    t.decimal "west"
    t.decimal "east"
    t.boolean "draggable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
  end

  create_table "usergroups_users", id: false, force: :cascade do |t|
    t.bigint "usergroup_id", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "usergroup_id"], name: "index_usergroups_users_on_user_id_and_usergroup_id"
    t.index ["usergroup_id", "user_id"], name: "index_usergroups_users_on_usergroup_id_and_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "update_frequency", default: 1
    t.integer "last_posting_within", default: 1
    t.boolean "allow_monitoring", default: false
    t.string "map_name"
    t.boolean "trace"
    t.boolean "admin_user"
    t.string "time_zone"
  end

  create_table "xmas_users", force: :cascade do |t|
    t.string "token"
    t.integer "stage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "latitude"
    t.decimal "longitude"
  end

end
