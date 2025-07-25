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

ActiveRecord::Schema.define(version: 2025_07_24_000300) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authors", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "book_categories", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["book_id"], name: "index_book_categories_on_book_id"
    t.index ["category_id"], name: "index_book_categories_on_category_id"
  end

  create_table "book_rentals", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "member_id", null: false
    t.date "issued_on", default: -> { "CURRENT_TIMESTAMP" }
    t.date "returned_on"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["book_id"], name: "index_book_rentals_on_book_id"
    t.index ["member_id"], name: "index_book_rentals_on_member_id"
  end

  create_table "books", force: :cascade do |t|
    t.text "name"
    t.integer "publishing_year"
    t.bigint "author_id"
    t.bigint "publisher_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "custom_number"
    t.index ["author_id"], name: "index_books_on_author_id"
    t.index ["custom_number"], name: "index_books_on_custom_number", unique: true
    t.index ["publisher_id"], name: "index_books_on_publisher_id"
  end

  create_table "categories", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "members", force: :cascade do |t|
    t.string "name"
    t.string "tamil_name"
    t.integer "personal_number"
    t.date "date_of_birth"
    t.date "date_of_retirement"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "section"
    t.string "custom_number"
    t.index ["custom_number"], name: "index_members_on_custom_number", unique: true
    t.index ["email"], name: "index_members_on_email", unique: true
    t.index ["personal_number"], name: "index_members_on_personal_number", unique: true
    t.index ["phone"], name: "index_members_on_phone", unique: true
  end

  create_table "publishers", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "staffs", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.bigint "role_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "remember_digest"
    t.index ["role_id"], name: "index_staffs_on_role_id"
  end

  add_foreign_key "book_categories", "books"
  add_foreign_key "book_categories", "categories"
  add_foreign_key "book_rentals", "books"
  add_foreign_key "book_rentals", "members"
  add_foreign_key "books", "authors"
  add_foreign_key "books", "publishers"
  add_foreign_key "staffs", "roles"
end
