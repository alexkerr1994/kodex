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

ActiveRecord::Schema[8.1].define(version: 2026_10_03_120133) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "archivals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "note_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["note_id"], name: "index_archivals_on_note_id"
    t.index ["user_id", "note_id"], name: "index_archivals_on_user_id_and_note_id", unique: true
    t.index ["user_id"], name: "index_archivals_on_user_id"
  end

  create_table "calendar_network_shares", force: :cascade do |t|
    t.integer "calendar_id", null: false
    t.datetime "created_at", null: false
    t.integer "network_id", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id", "network_id"], name: "index_calendar_network_shares_on_calendar_id_and_network_id", unique: true
    t.index ["calendar_id"], name: "index_calendar_network_shares_on_calendar_id"
    t.index ["network_id"], name: "index_calendar_network_shares_on_network_id"
  end

  create_table "calendar_shares", force: :cascade do |t|
    t.integer "calendar_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["calendar_id", "user_id"], name: "index_calendar_shares_on_calendar_id_and_user_id", unique: true
    t.index ["calendar_id"], name: "index_calendar_shares_on_calendar_id"
    t.index ["user_id"], name: "index_calendar_shares_on_user_id"
  end

  create_table "calendars", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "name"], name: "index_calendars_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_calendars_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.boolean "all_day", default: false, null: false
    t.integer "calendar_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "ends_at"
    t.integer "recurrence", default: 0, null: false
    t.date "recurrence_until"
    t.datetime "starts_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_events_on_calendar_id"
    t.index ["starts_at"], name: "index_events_on_starts_at"
  end

  create_table "favorites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "note_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["note_id"], name: "index_favorites_on_note_id"
    t.index ["user_id", "note_id"], name: "index_favorites_on_user_id_and_note_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "folders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "name"], name: "index_folders_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_folders_on_user_id"
  end

  create_table "network_invitations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "invited_by_id", null: false
    t.integer "invited_user_id", null: false
    t.integer "network_id", null: false
    t.datetime "updated_at", null: false
    t.index ["invited_by_id"], name: "index_network_invitations_on_invited_by_id"
    t.index ["invited_user_id"], name: "index_network_invitations_on_invited_user_id"
    t.index ["network_id", "invited_user_id"], name: "index_network_invitations_on_network_id_and_invited_user_id", unique: true
    t.index ["network_id"], name: "index_network_invitations_on_network_id"
  end

  create_table "network_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "network_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["network_id", "user_id"], name: "index_network_memberships_on_network_id_and_user_id", unique: true
    t.index ["network_id"], name: "index_network_memberships_on_network_id"
    t.index ["user_id"], name: "index_network_memberships_on_user_id"
  end

  create_table "networks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "note_filings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "folder_id", null: false
    t.integer "note_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["folder_id"], name: "index_note_filings_on_folder_id"
    t.index ["note_id"], name: "index_note_filings_on_note_id"
    t.index ["user_id", "note_id"], name: "index_note_filings_on_user_id_and_note_id", unique: true
    t.index ["user_id"], name: "index_note_filings_on_user_id"
  end

  create_table "note_memberships", force: :cascade do |t|
    t.integer "access_level", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "note_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["note_id"], name: "index_note_memberships_on_note_id"
    t.index ["user_id", "note_id"], name: "index_note_memberships_on_user_id_and_note_id", unique: true
    t.index ["user_id"], name: "index_note_memberships_on_user_id"
  end

  create_table "note_network_shares", force: :cascade do |t|
    t.integer "access_level", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "network_id", null: false
    t.integer "note_id", null: false
    t.datetime "updated_at", null: false
    t.index ["network_id"], name: "index_note_network_shares_on_network_id"
    t.index ["note_id", "network_id"], name: "index_note_network_shares_on_note_id_and_network_id", unique: true
    t.index ["note_id"], name: "index_note_network_shares_on_note_id"
  end

  create_table "note_shared_tags", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "note_id", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id", "name"], name: "index_note_shared_tags_on_note_id_and_name", unique: true
    t.index ["note_id"], name: "index_note_shared_tags_on_note_id"
  end

  create_table "note_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "note_id", null: false
    t.integer "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id", "tag_id"], name: "index_note_tags_on_note_id_and_tag_id", unique: true
    t.index ["note_id"], name: "index_note_tags_on_note_id"
    t.index ["tag_id"], name: "index_note_tags_on_tag_id"
  end

  create_table "note_views", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_viewed_at", null: false
    t.integer "note_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["note_id"], name: "index_note_views_on_note_id"
    t.index ["user_id", "note_id"], name: "index_note_views_on_user_id_and_note_id", unique: true
    t.index ["user_id"], name: "index_note_views_on_user_id"
  end

  create_table "notes", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.integer "last_edited_by_id"
    t.integer "owner_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_notes_on_discarded_at"
    t.index ["last_edited_by_id"], name: "index_notes_on_last_edited_by_id"
    t.index ["owner_id"], name: "index_notes_on_owner_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "name"], name: "index_tags_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "default_view", default: "list", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "holiday_region"
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.boolean "start_collapsed", default: false, null: false
    t.string "theme", default: "quill", null: false
    t.string "time_zone"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "archivals", "notes"
  add_foreign_key "archivals", "users"
  add_foreign_key "calendar_network_shares", "calendars"
  add_foreign_key "calendar_network_shares", "networks"
  add_foreign_key "calendar_shares", "calendars"
  add_foreign_key "calendar_shares", "users"
  add_foreign_key "calendars", "users"
  add_foreign_key "events", "calendars"
  add_foreign_key "favorites", "notes"
  add_foreign_key "favorites", "users"
  add_foreign_key "folders", "users"
  add_foreign_key "network_invitations", "networks"
  add_foreign_key "network_invitations", "users", column: "invited_by_id"
  add_foreign_key "network_invitations", "users", column: "invited_user_id"
  add_foreign_key "network_memberships", "networks"
  add_foreign_key "network_memberships", "users"
  add_foreign_key "note_filings", "folders"
  add_foreign_key "note_filings", "notes"
  add_foreign_key "note_filings", "users"
  add_foreign_key "note_memberships", "notes"
  add_foreign_key "note_memberships", "users"
  add_foreign_key "note_network_shares", "networks"
  add_foreign_key "note_network_shares", "notes"
  add_foreign_key "note_shared_tags", "notes"
  add_foreign_key "note_tags", "notes"
  add_foreign_key "note_tags", "tags"
  add_foreign_key "note_views", "notes"
  add_foreign_key "note_views", "users"
  add_foreign_key "notes", "users", column: "last_edited_by_id"
  add_foreign_key "notes", "users", column: "owner_id"
  add_foreign_key "tags", "users"
end
