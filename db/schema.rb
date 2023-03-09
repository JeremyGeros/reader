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

ActiveRecord::Schema[7.0].define(version: 2023_03_09_165437) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "articles", force: :cascade do |t|
    t.string "url"
    t.string "name"
    t.text "extracted_text"
    t.string "subtitle"
    t.bigint "source_id"
    t.bigint "user_id", null: false
    t.integer "read_status", default: 0, null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parse_progress", default: 0, null: false
    t.string "byline"
    t.text "extracted_content"
    t.text "excerpt"
    t.string "language"
    t.datetime "published_at"
    t.integer "ttr", default: 0, null: false
    t.text "edited_content"
    t.bigint "import_id"
    t.boolean "starred", default: false, null: false
    t.index ["source_id"], name: "index_articles_on_source_id"
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "imports", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.integer "import_from"
    t.integer "status", default: 0, null: false
    t.integer "articles_count"
    t.string "failed_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_imports_on_user_id"
  end

  create_table "notes", force: :cascade do |t|
    t.text "text", null: false
    t.bigint "article_id", null: false
    t.bigint "user_id", null: false
    t.integer "highlight_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_notes_on_article_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "sources", force: :cascade do |t|
    t.string "url", null: false
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.integer "scan_interval", default: 0, null: false
    t.datetime "last_scanned_at"
    t.datetime "enabled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "temporary_at"
    t.integer "scan_progress", default: 0, null: false
    t.string "rss_url"
    t.index ["user_id"], name: "index_sources_on_user_id"
  end

  create_table "user_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "key", null: false
    t.datetime "accessed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_user_sessions_on_key", unique: true
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "time_zone", default: "UTC", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "preferred_size", default: 1, null: false
    t.integer "preferred_code_style", default: 0, null: false
    t.integer "preferred_font", default: 0, null: false
    t.integer "preferred_theme", default: 0, null: false
    t.integer "preferred_font_size", default: 1, null: false
    t.boolean "sidebar_collapsed", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "articles", "sources"
  add_foreign_key "articles", "users"
  add_foreign_key "imports", "users"
  add_foreign_key "notes", "articles"
  add_foreign_key "notes", "users"
  add_foreign_key "sources", "users"
  add_foreign_key "user_sessions", "users"
end
