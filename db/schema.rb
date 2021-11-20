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

ActiveRecord::Schema.define(version: 2021_11_19_140444) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "guests", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_guests_on_email", unique: true
  end

  create_table "reservations", force: :cascade do |t|
    t.string "reservation_code", limit: 11, null: false
    t.date "start_date"
    t.date "end_date"
    t.integer "nights"
    t.integer "guests"
    t.integer "adults"
    t.integer "children"
    t.integer "infants"
    t.integer "status"
    t.string "currency", limit: 3, null: false
    t.decimal "payout_price", precision: 10, scale: 2
    t.decimal "security_price", precision: 10, scale: 2
    t.decimal "total_price", precision: 10, scale: 2
    t.text "localized_description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "guest_id"
    t.index ["guest_id"], name: "index_reservations_on_guest_id"
    t.index ["reservation_code"], name: "index_reservations_on_reservation_code", unique: true
  end

  add_foreign_key "reservations", "guests"
end
