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

ActiveRecord::Schema[8.0].define(version: 2026_05_05_114500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "amenities", force: :cascade do |t|
    t.bigint "amenity_category_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "display_priority", default: 999, null: false
    t.boolean "always_shown_if_absent", default: false, null: false
    t.string "absence_description"
    t.boolean "searchable", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["always_shown_if_absent"], name: "index_amenities_on_always_shown_if_absent"
    t.index ["amenity_category_id"], name: "index_amenities_on_amenity_category_id"
    t.index ["display_priority"], name: "index_amenities_on_display_priority"
    t.index ["slug"], name: "index_amenities_on_slug", unique: true
  end

  create_table "amenity_categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "display_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["display_order"], name: "index_amenity_categories_on_display_order"
    t.index ["slug"], name: "index_amenity_categories_on_slug", unique: true
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "property_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_favorites_on_property_id"
    t.index ["user_id", "property_id"], name: "index_favorites_on_user_id_and_property_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "reservation_id", null: false
    t.integer "base_fare_cents"
    t.string "base_fare_currency"
    t.integer "total_amount_cents"
    t.string "total_amount_currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "service_fee_ratio", precision: 5, scale: 4, default: "0.0"
    t.string "stripe_checkout_session_id"
    t.index ["reservation_id"], name: "index_payments_on_reservation_id"
    t.index ["stripe_checkout_session_id"], name: "index_payments_on_stripe_checkout_session_id", unique: true
  end

  create_table "properties", force: :cascade do |t|
    t.string "name"
    t.string "headline"
    t.text "description"
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_cents"
    t.string "price_currency"
    t.integer "reviews_count"
    t.decimal "average_final_rating"
    t.integer "guest_count", default: 0
    t.integer "bedroom_count", default: 0
    t.integer "bed_count", default: 0
    t.integer "bathroom_count", default: 0
  end

  create_table "property_amenities", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "amenity_id", null: false
    t.boolean "available", default: false, null: false
    t.string "details"
    t.boolean "extra_cost", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amenity_id"], name: "index_property_amenities_on_amenity_id"
    t.index ["property_id", "amenity_id"], name: "index_property_amenities_on_property_id_and_amenity_id", unique: true
    t.index ["property_id"], name: "index_property_amenities_on_property_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "property_id", null: false
    t.date "checkin_date", null: false
    t.date "checkout_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_reservations_on_property_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
    t.check_constraint "checkout_date > checkin_date", name: "reservations_checkout_after_checkin"
    t.exclusion_constraint "property_id WITH =, daterange(checkin_date, checkout_date, '[)'::text) WITH &&", using: :gist, name: "reservations_no_overlapping_dates_per_property"
  end

  create_table "reviews", force: :cascade do |t|
    t.string "content"
    t.integer "cleanliness_rating"
    t.integer "accuracy_rating"
    t.integer "checkin_rating"
    t.integer "communication_rating"
    t.integer "location_rating"
    t.integer "value_rating"
    t.decimal "final_rating"
    t.bigint "user_id", null: false
    t.bigint "property_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_reviews_on_property_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "country"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "amenities", "amenity_categories"
  add_foreign_key "favorites", "properties"
  add_foreign_key "favorites", "users"
  add_foreign_key "payments", "reservations"
  add_foreign_key "property_amenities", "amenities"
  add_foreign_key "property_amenities", "properties"
  add_foreign_key "reservations", "properties"
  add_foreign_key "reservations", "users"
  add_foreign_key "reviews", "properties"
  add_foreign_key "reviews", "users"
end
