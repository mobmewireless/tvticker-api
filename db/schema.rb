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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111219060337) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version_id"
  end

  add_index "categories", ["version_id"], :name => "index_categories_on_version_id"

  create_table "channels", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version_id"
  end

  add_index "channels", ["version_id"], :name => "index_channels_on_version_id"

  create_table "programs", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.integer  "series_id"
    t.integer  "channel_id"
    t.datetime "air_time_start"
    t.datetime "air_time_end"
    t.integer  "run_time",       :limit => 8, :default => 0
    t.text     "imdb_info"
    t.text     "description"
    t.text     "thumbnail_link"
    t.string   "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version_id"
  end

  add_index "programs", ["version_id"], :name => "index_programs_on_version_id"

  create_table "series", :force => true do |t|
    t.string   "name"
    t.text     "imdb_info"
    t.text     "description"
    t.text     "thumbnail_link"
    t.string   "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version_id"
  end

  add_index "series", ["version_id"], :name => "index_series_on_version_id"

  create_table "thumbnails", :force => true do |t|
    t.string   "name"
    t.text     "original_link"
    t.text     "thumbnail_link"
    t.string   "image"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version_id"
  end

  add_index "thumbnails", ["version_id"], :name => "index_thumbnails_on_version_id"

  create_table "versions", :force => true do |t|
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["number"], :name => "index_versions_on_number", :unique => true

end
