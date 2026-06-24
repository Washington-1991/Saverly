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

ActiveRecord::Schema[7.2].define(version: 2026_06_24_134337) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "current_balance", precision: 12, scale: 2, default: "0.0", null: false
    t.boolean "external", default: false, null: false
    t.index ["current_balance"], name: "index_accounts_on_current_balance"
    t.index ["external"], name: "index_accounts_on_external"
    t.index ["user_id", "name"], name: "index_accounts_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "movements", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "date", null: false
    t.string "description"
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "source_account_id"
    t.bigint "destination_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "movement_type"
    t.index ["destination_account_id"], name: "index_movements_on_destination_account_id"
    t.index ["source_account_id"], name: "index_movements_on_source_account_id"
    t.index ["user_id", "date"], name: "index_movements_on_user_id_and_date"
    t.index ["user_id"], name: "index_movements_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", null: false
    t.string "role", default: "user", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "movements", "accounts", column: "destination_account_id"
  add_foreign_key "movements", "accounts", column: "source_account_id"
  add_foreign_key "movements", "users"
end
