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

ActiveRecord::Schema.define(version: 20140423221700) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "groupings", force: true do |t|
    t.string   "key_line"
    t.string   "error_class"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                      default: "active", null: false
    t.datetime "last_emailed_at"
    t.text     "message"
    t.decimal  "popularity",      precision: 1000, scale: 1
    t.datetime "latest_wat_at"
  end

  add_index "groupings", ["key_line", "error_class"], name: "index_groupings_on_key_line_and_error_class", using: :btree
  add_index "groupings", ["latest_wat_at"], name: "index_groupings_on_latest_wat_at", using: :btree
  add_index "groupings", ["message"], name: "index_groupings_on_message", using: :btree
  add_index "groupings", ["popularity"], name: "index_groupings_on_popularity", using: :btree
  add_index "groupings", ["state"], name: "index_groupings_on_state", using: :btree

  create_table "notes", force: true do |t|
    t.integer  "watcher_id"
    t.integer  "grouping_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["grouping_id"], name: "index_notes_on_grouping_id", using: :btree
  add_index "notes", ["watcher_id"], name: "index_notes_on_watcher_id", using: :btree

  create_table "watchers", force: true do |t|
    t.string   "first_name"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wats", force: true do |t|
    t.text     "message"
    t.text     "error_class"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.hstore   "session"
    t.hstore   "request_headers"
    t.hstore   "request_params"
    t.text     "page_url"
    t.text     "app_env",         default: "unknown",   null: false
    t.hstore   "sidekiq_msg"
    t.text     "app_name",        default: "unknown",   null: false
    t.text     "backtrace",                                          array: true
    t.string   "language"
    t.hstore   "app_user",        default: {"id"=>nil}
    t.datetime "captured_at",                           null: false
  end

  add_index "wats", ["app_env"], name: "index_wats_on_app_env", using: :btree
  add_index "wats", ["app_name"], name: "index_wats_on_app_name", using: :btree
  add_index "wats", ["app_user"], name: "wats_user_index", using: :gin
  add_index "wats", ["captured_at"], name: "index_wats_on_captured_at", using: :btree
  add_index "wats", ["created_at"], name: "index_wats_on_created_at", using: :btree
  add_index "wats", ["language"], name: "index_wats_on_language", using: :btree

  create_table "wats_groupings", force: true do |t|
    t.integer  "wat_id",      null: false
    t.integer  "grouping_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",       null: false
  end

  add_index "wats_groupings", ["grouping_id", "wat_id"], name: "index_wats_groupings_on_grouping_id_and_wat_id", unique: true, using: :btree
  add_index "wats_groupings", ["grouping_id"], name: "index_wats_groupings_on_grouping_id", using: :btree
  add_index "wats_groupings", ["state", "grouping_id", "wat_id"], name: "index_wats_groupings_on_state_and_grouping_id_and_wat_id", using: :btree
  add_index "wats_groupings", ["wat_id"], name: "index_wats_groupings_on_wat_id", using: :btree

end
