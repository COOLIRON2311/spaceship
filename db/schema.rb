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

ActiveRecord::Schema.define(version: 2022_04_29_194204) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ips", force: :cascade do |t|
    t.string "ip"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ip", "user_id"], name: "index_ips_on_ip_and_user_id", unique: true
    t.index ["user_id"], name: "index_ips_on_user_id"
  end

  create_table "stats", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.float "percent"
    t.float "time"
    t.integer "calls"
    t.float "min"
    t.float "max"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["task_id"], name: "index_stats_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "result"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "login"
    t.string "password_hash"
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "ips", "users"
  add_foreign_key "stats", "tasks"
  add_foreign_key "tasks", "users"
end
