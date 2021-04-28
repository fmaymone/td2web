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

ActiveRecord::Schema.define(version: 2021_11_27_213425) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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

  create_table "diagnostic_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "slug", null: false
    t.uuid "diagnostic_id"
    t.string "body", null: false
    t.string "body_positive"
    t.integer "category", null: false
    t.integer "question_type", null: false
    t.integer "factor", null: false
    t.integer "matrix", null: false
    t.boolean "negative", default: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "weight", default: "0.0", null: false
    t.index ["active", "category", "question_type", "factor", "matrix", "weight"], name: "general_idx"
    t.index ["diagnostic_id"], name: "index_diagnostic_questions_on_diagnostic_id"
    t.index ["slug"], name: "index_diagnostic_questions_on_slug", unique: true
  end

  create_table "diagnostic_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "diagnostic_survey_id", null: false
    t.uuid "team_diagnostic_question_id", null: false
    t.string "locale", null: false
    t.text "response", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["diagnostic_survey_id", "team_diagnostic_question_id", "locale"], name: "diagnostic_responses_unique_idx", unique: true
  end

  create_table "diagnostic_surveys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "team_diagnostic_id", null: false
    t.uuid "participant_id", null: false
    t.string "state", default: "pending", null: false
    t.string "locale", default: "en", null: false
    t.text "notes"
    t.datetime "last_activity_at"
    t.datetime "delivered_at"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["team_diagnostic_id", "participant_id", "state"], name: "diagnostic_surveys_idx"
  end

  create_table "diagnostics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
    t.text "description", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_diagnostics_on_slug", unique: true
  end

  create_table "entitlements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "account", default: true, null: false
    t.boolean "active", default: true, null: false
    t.uuid "role_id", null: false
    t.string "reference", null: false
    t.string "slug", null: false
    t.text "description"
    t.integer "quota"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug", "role_id", "reference", "active"], name: "index_entitlements_on_slug_and_role_id_and_reference_and_active"
    t.index ["slug"], name: "index_entitlements_on_slug", unique: true
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

  create_table "grant_usages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "grant_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["grant_id"], name: "index_grant_usages_on_grant_id"
  end

  create_table "grants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true
    t.uuid "user_id", null: false
    t.string "reference", null: false
    t.uuid "entitlement_id", null: false
    t.uuid "grantor_id"
    t.string "grantor_type"
    t.integer "quota"
    t.text "description"
    t.text "staff_notes"
    t.datetime "granted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "reference"], name: "index_grants_on_user_id_and_reference"
  end

  create_table "invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tenant_id"
    t.boolean "active", default: true
    t.string "token"
    t.uuid "grantor_id"
    t.string "grantor_type"
    t.jsonb "entitlements"
    t.string "email"
    t.text "description"
    t.string "redirect"
    t.string "locale", default: "en"
    t.string "i18n_key"
    t.datetime "claimed_at"
    t.uuid "claimed_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["claimed_by_id"], name: "index_invitations_on_claimed_by_id"
    t.index ["tenant_id", "active", "token"], name: "index_invitations_on_tenant_id_and_active_and_token"
  end

  create_table "organization_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "user_id", null: false
    t.integer "role", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id", "user_id"], name: "index_organization_users_on_organization_id_and_user_id", unique: true
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tenant_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "url", null: false
    t.integer "industry", null: false
    t.integer "revenue", null: false
    t.string "locale", default: "en", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "participants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "team_diagnostic_id", null: false
    t.string "state", default: "approved", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "title"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "locale", null: false
    t.string "timezone", null: false
    t.text "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "metadata", default: ""
    t.index ["team_diagnostic_id", "email"], name: "index_participants_on_team_diagnostic_id_and_email", unique: true
    t.index ["team_diagnostic_id", "state"], name: "index_participants_on_team_diagnostic_id_and_state"
  end

  create_table "report_template_pages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "report_template_id"
    t.string "slug"
    t.integer "index"
    t.string "locale"
    t.string "format"
    t.string "name"
    t.text "markup"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["report_template_id", "format", "locale", "index"], name: "order_idx"
    t.index ["report_template_id", "slug", "format", "locale"], name: "slug_idx", unique: true
  end

  create_table "report_templates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "tenant_id", null: false
    t.uuid "diagnostic_id", null: false
    t.string "name", null: false
    t.string "state", default: "draft", null: false
    t.integer "version", default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tenant_id", "diagnostic_id", "state", "version"], name: "report_templates_idx"
  end

  create_table "reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "team_diagnostic_id"
    t.uuid "report_template_id"
    t.string "state", default: "pending", null: false
    t.integer "version", default: 1, null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.string "description"
    t.text "note"
    t.uuid "token"
    t.json "chart_data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "options", default: {}
    t.index ["team_diagnostic_id", "state", "version"], name: "index_reports_on_team_diagnostic_id_and_state_and_version"
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

  create_table "system_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "event_source_type", null: false
    t.uuid "event_source_id", null: false
    t.string "incidental_type"
    t.uuid "incidental_id"
    t.string "description"
    t.text "debug"
    t.integer "severity", default: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_source_type", "event_source_id"], name: "index_system_events_on_event_source_type_and_event_source_id"
    t.index ["incidental_type", "incidental_id"], name: "index_system_events_on_incidental_type_and_incidental_id"
  end

  create_table "team_diagnostic_letters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "team_diagnostic_id"
    t.integer "letter_type"
    t.string "locale", default: "en"
    t.string "subject"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["team_diagnostic_id", "letter_type", "locale"], name: "tdl_general_idx", unique: true
  end

  create_table "team_diagnostic_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "slug", default: "OEQ", null: false
    t.uuid "team_diagnostic_id"
    t.string "body", null: false
    t.string "body_positive"
    t.integer "category", default: 0, null: false
    t.integer "question_type", default: 1, null: false
    t.integer "factor", default: 0, null: false
    t.integer "matrix", default: 0, null: false
    t.boolean "negative", default: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "locale", default: "en"
    t.index ["active", "category", "question_type", "factor", "matrix"], name: "tdq_general_idx"
    t.index ["slug"], name: "index_team_diagnostic_questions_on_slug"
    t.index ["team_diagnostic_id"], name: "index_team_diagnostic_questions_on_team_diagnostic_id"
  end

  create_table "team_diagnostics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "user_id", null: false
    t.uuid "team_diagnostic_id"
    t.uuid "diagnostic_id", null: false
    t.string "state", default: "setup", null: false
    t.string "locale", default: "en", null: false
    t.string "timezone", null: false
    t.string "name", null: false
    t.text "description", null: false
    t.text "situation"
    t.string "functional_area", null: false
    t.string "team_type", null: false
    t.boolean "show_members", default: true, null: false
    t.string "contact_phone", null: false
    t.string "contact_email", null: false
    t.string "alternate_email"
    t.datetime "due_at", null: false
    t.datetime "completed_at"
    t.datetime "deployed_at"
    t.datetime "auto_deploy_at"
    t.datetime "reminder_at"
    t.datetime "reminder_sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "wizard", default: 1, null: false
    t.index ["team_diagnostic_id"], name: "index_team_diagnostics_on_team_diagnostic_id"
    t.index ["user_id", "organization_id", "state"], name: "index_team_diagnostics_on_user_id_and_organization_id_and_state"
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
    t.string "phone_number", null: false
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
