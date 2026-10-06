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

ActiveRecord::Schema[8.1].define(version: 2026_10_05_120003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.bigint "channel_hash", null: false
    t.datetime "created_at", null: false
    t.binary "payload", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_batch_executions", force: :cascade do |t|
    t.bigint "batch_id", null: false
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.index ["batch_id"], name: "index_solid_queue_batch_executions_on_batch_id"
    t.index ["job_id"], name: "index_solid_queue_batch_executions_on_job_id", unique: true
  end

  create_table "solid_queue_batches", force: :cascade do |t|
    t.string "active_job_batch_id"
    t.integer "completed_jobs", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.datetime "enqueued_at"
    t.datetime "failed_at"
    t.integer "failed_jobs", default: 0, null: false
    t.datetime "finished_at"
    t.text "metadata"
    t.text "on_failure"
    t.text "on_finish"
    t.text "on_success"
    t.integer "total_jobs", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_batch_id"], name: "index_solid_queue_batches_on_active_job_batch_id", unique: true
    t.index ["finished_at"], name: "index_solid_queue_batches_on_finished_at"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.bigint "batch_id"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["batch_id"], name: "index_solid_queue_jobs_on_batch_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
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
  add_foreign_key "solid_queue_batch_executions", "solid_queue_batches", column: "batch_id", on_delete: :cascade
  add_foreign_key "solid_queue_batch_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "tags", "users"
end
