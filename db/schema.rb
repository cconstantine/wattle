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

ActiveRecord::Schema.define(version: 20130405042638) do

  create_table "groupings", force: true do |t|
    t.string   "key_line"
    t.string   "error_class"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groupings", ["key_line", "error_class"], name: "index_groupings_on_key_line_and_error_class"

  create_table "wats", force: true do |t|
    t.string   "backtrace",   array: true
    t.text     "message"
    t.string   "error_class"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wats_groupings", force: true do |t|
    t.integer  "wat_id",      null: false
    t.integer  "grouping_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wats_groupings", ["grouping_id", "wat_id"], name: "index_wats_groupings_on_grouping_id_and_wat_id", unique: true
  add_index "wats_groupings", ["grouping_id"], name: "index_wats_groupings_on_grouping_id"
  add_index "wats_groupings", ["wat_id"], name: "index_wats_groupings_on_wat_id"

end
