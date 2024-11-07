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

ActiveRecord::Schema[8.0].define(version: 2024_11_07_163412) do
  create_table "currencies", force: :cascade do |t|
    t.string "name", null: false
    t.string "symbol", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["symbol"], name: "index_currencies_on_symbol", unique: true
  end

  create_table "orders", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "side", null: false
    t.integer "status", null: false
    t.bigint "base_currency", null: false
    t.bigint "quote_currency", null: false
    t.integer "volume", null: false
    t.float "price", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "currency_id", null: false
    t.bigint "balance", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_wallets_on_currency_id"
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "orders", "currencies", column: "base_currency"
  add_foreign_key "orders", "currencies", column: "quote_currency"
  add_foreign_key "orders", "users"
  add_foreign_key "wallets", "currencies"
  add_foreign_key "wallets", "users"
end
