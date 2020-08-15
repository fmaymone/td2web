# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_29_231528) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "globalize_countries", id: :bigint, default: nil, force: :cascade do |t|
    t.string "code", limit: 2
    t.string "english_name", limit: 255
    t.string "date_format", limit: 255
    t.string "currency_format", limit: 255
    t.string "currency_code", limit: 3
    t.string "thousands_sep", limit: 2
    t.string "decimal_sep", limit: 2
    t.string "currency_decimal_sep", limit: 2
    t.string "number_grouping_scheme", limit: 255
    t.index ["code"], name: "idx_4871306_globalize_countries_code_index"
  end

  create_table "globalize_languages", force: :cascade do |t|
    t.string "iso_639_1", limit: 2
    t.string "iso_639_2", limit: 3
    t.string "iso_639_3", limit: 3
    t.string "rfc_3066", limit: 255
    t.string "english_name", limit: 255
    t.string "english_name_locale", limit: 255
    t.string "english_name_modifier", limit: 255
    t.string "native_name", limit: 255
    t.string "native_name_locale", limit: 255
    t.string "native_name_modifier", limit: 255
    t.boolean "macro_language"
    t.string "direction", limit: 255
    t.string "pluralization", limit: 255
    t.string "scope", limit: 1
    t.index ["iso_639_1"], name: "idx_4871315_globalize_languages_iso_639_1_index"
    t.index ["iso_639_2"], name: "idx_4871315_globalize_languages_iso_639_2_index"
    t.index ["iso_639_3"], name: "idx_4871315_globalize_languages_iso_639_3_index"
    t.index ["rfc_3066"], name: "idx_4871315_globalize_languages_rfc_3066_index"
  end

  create_table "globalize_translations", id: :bigint, default: nil, force: :cascade do |t|
    t.string "type", limit: 255
    t.string "tr_key", limit: 512
    t.string "table_name", limit: 255
    t.bigint "item_id"
    t.string "facet", limit: 255
    t.boolean "built_in"
    t.bigint "language_id"
    t.bigint "pluralization_index"
    t.text "text"
    t.string "namespace", limit: 255
    t.index ["table_name", "item_id", "language_id"], name: "idx_4871324_globalize_translations_table_name_index"
    t.index ["tr_key", "language_id"], name: "idx_4871324_globalize_translations_tr_key_index"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
    t.index ["slug"], name: "index_roles_on_slug", unique: true
  end

  create_table "tenants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "domain"
    t.text "description"
    t.boolean "active", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "locale", default: "en"
    t.index ["domain", "active"], name: "index_tenants_on_domain_and_active"
  end

  create_table "translations", force: :cascade do |t|
    t.string "locale", null: false
    t.string "key", null: false
    t.text "value", null: false
    t.text "interpolations"
    t.boolean "is_proc", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["locale", "key"], name: "index_translations_on_locale_and_key", unique: true
  end

  create_table "user_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.string "prefix", default: ""
    t.string "first_name", default: ""
    t.string "middle_name", default: ""
    t.string "last_name"
    t.string "suffix", default: ""
    t.string "pronoun", default: "they"
    t.string "country"
    t.string "company"
    t.string "department"
    t.string "title"
    t.integer "ux_version", default: 0
    t.jsonb "consent"
    t.text "staff_notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
    t.index ["ux_version"], name: "index_user_profiles_on_ux_version"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tenant_id", null: false
    t.uuid "role_id", null: false
    t.string "locale", default: "en", null: false
    t.string "timezone", default: "Pacific Time (US & Canada)", null: false
    t.string "username", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
