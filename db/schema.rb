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

ActiveRecord::Schema.define(:version => 20130129135900) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "reservations", :force => true do |t|
    t.integer  "room_id"
    t.integer  "author_id"
    t.text     "description"
    t.string   "summary"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.datetime "start"
    t.datetime "end"
    t.text     "scheduleyaml"
  end

  add_index "reservations", ["author_id"], :name => "index_reservations_on_author_id"
  add_index "reservations", ["room_id"], :name => "index_reservations_on_room_id"

  create_table "rooms", :force => true do |t|
    t.string   "name"
    t.integer  "capacity"
    t.string   "location"
    t.string   "equipment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "cal_url"
  end

  create_table "temp_reservations", :force => true do |t|
    t.integer  "room_id"
    t.datetime "start"
    t.datetime "end"
    t.text     "description"
    t.string   "summary"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.text     "scheduleyaml"
  end

  add_index "temp_reservations", ["room_id"], :name => "index_temp_reservations_on_room_id"

  create_table "users", :force => true do |t|
    t.string   "login",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "name"
    t.string   "email"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
