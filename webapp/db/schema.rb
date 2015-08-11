# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141021025346) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "answers", force: true do |t|
    t.integer  "review_id"
    t.integer  "question_id"
    t.integer  "waiting_time"
    t.integer  "rating",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "price",        default: 0
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree
  add_index "answers", ["review_id"], name: "index_answers_on_review_id", using: :btree

  create_table "audit_logs", force: true do |t|
    t.string   "action"
    t.integer  "record_id"
    t.string   "record_type"
    t.json     "record_attributes"
    t.json     "record_before_attributes"
    t.json     "record_changes"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audit_logs", ["record_id"], name: "index_audit_logs_on_record_id", using: :btree
  add_index "audit_logs", ["record_type"], name: "index_audit_logs_on_record_type", using: :btree
  add_index "audit_logs", ["user_id"], name: "index_audit_logs_on_user_id", using: :btree

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token_secret"
  end

  add_index "authentications", ["provider"], name: "index_authentications_on_provider", using: :btree
  add_index "authentications", ["uid"], name: "index_authentications_on_uid", using: :btree
  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "blacklists", force: true do |t|
    t.string   "word"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blacklists", ["word"], name: "index_blacklists_on_word", using: :btree

  create_table "cegedim_companies", force: true do |t|
    t.integer  "uid"
    t.string   "en_name"
    t.string   "cn_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cegedim_companies", ["uid"], name: "index_cegedim_companies_on_uid", using: :btree

  create_table "cegedim_companies_medications", force: true do |t|
    t.integer  "company_uid"
    t.integer  "medication_uid"
    t.date     "begin_at"
    t.date     "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cegedim_companies_medications", ["company_uid"], name: "index_cegedim_companies_medications_on_company_uid", using: :btree
  add_index "cegedim_companies_medications", ["medication_uid"], name: "index_cegedim_companies_medications_on_medication_uid", using: :btree

  create_table "cegedim_departments", force: true do |t|
    t.string   "uid"
    t.string   "hospital_uid"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cegedim_hospitals", force: true do |t|
    t.string   "uid"
    t.string   "parent_uid"
    t.string   "name"
    t.string   "official_name"
    t.string   "phone"
    t.string   "address"
    t.string   "post_code"
    t.string   "city"
    t.string   "district"
    t.string   "h_type"
    t.string   "h_class"
    t.string   "status",        default: "open"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cegedim_medications", force: true do |t|
    t.integer  "uid"
    t.integer  "master_uid"
    t.string   "old_companies", default: [], array: true
    t.string   "code"
    t.string   "en_name"
    t.string   "cn_name"
    t.integer  "otc"
    t.string   "dosage1"
    t.string   "dosage2"
    t.string   "dosage3"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cegedim_physicians", force: true do |t|
    t.string   "uid"
    t.string   "department_uid"
    t.string   "hospital_uid"
    t.string   "name"
    t.string   "position"
    t.string   "gender"
    t.date     "birthdate"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cegedim_physicians_specialities", force: true do |t|
    t.string   "physician_uid"
    t.integer  "speciality_id"
    t.integer  "priority",      default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cegedim_specialities", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: true do |t|
    t.integer  "writer_id"
    t.integer  "user_id"
    t.text     "content"
    t.string   "status",     default: "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree
  add_index "comments", ["writer_id"], name: "index_comments_on_writer_id", using: :btree

  create_table "companies", force: true do |t|
    t.integer  "vendor_id"
    t.string   "en_name"
    t.string   "cn_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "companies", ["vendor_id"], name: "index_companies_on_vendor_id", using: :btree

  create_table "companies_medications", force: true do |t|
    t.integer  "company_id"
    t.integer  "medication_id"
    t.date     "begin_at"
    t.date     "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "companies_medications", ["company_id"], name: "index_companies_medications_on_company_id", using: :btree
  add_index "companies_medications", ["medication_id"], name: "index_companies_medications_on_medication_id", using: :btree

  create_table "conditions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category"
  end

  create_table "departments", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "vendor_id"
  end

  add_index "departments", ["name"], name: "index_departments_on_name", using: :btree

  create_table "departments_hospitals", force: true do |t|
    t.integer "hospital_id"
    t.integer "department_id"
  end

  add_index "departments_hospitals", ["department_id"], name: "index_departments_hospitals_on_department_id", using: :btree
  add_index "departments_hospitals", ["hospital_id"], name: "index_departments_hospitals_on_hospital_id", using: :btree

  create_table "feedback", force: true do |t|
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "app_version"
    t.string   "device_model"
    t.string   "system_version"
  end

  add_index "feedback", ["user_id"], name: "index_feedback_on_user_id", using: :btree

  create_table "health_conditions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category"
    t.string   "type",       limit: 30
  end

  create_table "helpfuls", force: true do |t|
    t.integer  "review_id"
    t.integer  "user_id"
    t.datetime "created_at"
  end

  add_index "helpfuls", ["review_id"], name: "index_helpfuls_on_review_id", using: :btree
  add_index "helpfuls", ["user_id"], name: "index_helpfuls_on_user_id", using: :btree

  create_table "hospitals", force: true do |t|
    t.string   "vendor_id"
    t.string   "name"
    t.string   "official_name"
    t.string   "phone"
    t.string   "address"
    t.string   "post_code"
    t.string   "h_class"
    t.integer  "avg_waiting_time"
    t.float    "avg_rating",       default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "latitude",         default: 0.0
    t.decimal  "longitude",        default: 0.0
    t.string   "city"
    t.integer  "parent_id"
  end

  add_index "hospitals", ["avg_rating"], name: "index_hospitals_on_avg_rating", using: :btree
  add_index "hospitals", ["vendor_id"], name: "index_hospitals_on_vendor_id", using: :btree

  create_table "invitations", force: true do |t|
    t.string   "owner_email"
    t.string   "guest_email"
    t.datetime "created_at"
  end

  add_index "invitations", ["guest_email"], name: "index_invitations_on_guest_email", using: :btree
  add_index "invitations", ["owner_email"], name: "index_invitations_on_owner_email", using: :btree

  create_table "invite_requests", force: true do |t|
    t.integer  "user_id"
    t.string   "emails",     default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invite_requests", ["user_id"], name: "index_invite_requests_on_user_id", using: :btree

  create_table "medical_experiences", force: true do |t|
    t.integer  "user_id"
    t.integer  "referral_code_id"
    t.integer  "symptom_ids",                     array: true
    t.integer  "condition_ids",                   array: true
    t.boolean  "network_visible",  default: true
    t.string   "behalf"
    t.float    "completion",       default: 0.0
    t.float    "avg_rating",       default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hospital_id"
  end

  add_index "medical_experiences", ["condition_ids"], name: "index_medical_experiences_on_condition_ids", using: :btree
  add_index "medical_experiences", ["hospital_id"], name: "index_medical_experiences_on_hospital_id", using: :btree
  add_index "medical_experiences", ["referral_code_id"], name: "index_medical_experiences_on_referral_code_id", using: :btree
  add_index "medical_experiences", ["symptom_ids"], name: "index_medical_experiences_on_symptom_ids", using: :btree
  add_index "medical_experiences", ["user_id"], name: "index_medical_experiences_on_user_id", using: :btree

  create_table "medications", force: true do |t|
    t.integer  "vendor_id"
    t.string   "name"
    t.string   "code"
    t.float    "avg_rating",    default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "old_companies", default: [],  array: true
    t.integer  "master_id"
    t.string   "dosage1"
    t.string   "dosage2"
    t.string   "dosage3"
    t.integer  "ibn_id"
    t.string   "ibn_name"
    t.string   "ibn_code"
    t.integer  "eph_id"
    t.string   "eph_name"
    t.integer  "otc"
  end

  add_index "medications", ["master_id"], name: "index_medications_on_master_id", using: :btree
  add_index "medications", ["name"], name: "index_medications_on_name", using: :btree
  add_index "medications", ["vendor_id"], name: "index_medications_on_vendor_id", using: :btree

  create_table "physicians", force: true do |t|
    t.string   "vendor_id"
    t.string   "name"
    t.string   "position"
    t.float    "avg_rating",       default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "birthdate"
    t.string   "gender"
    t.integer  "department_id"
    t.integer  "hospital_id"
    t.integer  "avg_waiting_time"
    t.integer  "avg_price",        default: 0
    t.json     "doc"
  end

  add_index "physicians", ["department_id"], name: "index_physicians_on_department_id", using: :btree
  add_index "physicians", ["hospital_id"], name: "index_physicians_on_hospital_id", using: :btree
  add_index "physicians", ["name"], name: "index_physicians_on_name", using: :btree
  add_index "physicians", ["vendor_id"], name: "index_physicians_on_vendor_id", using: :btree

  create_table "physicians_specialities", force: true do |t|
    t.integer  "physician_id"
    t.integer  "speciality_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "priority"
  end

  add_index "physicians_specialities", ["physician_id"], name: "index_physicians_specialities_on_physician_id", using: :btree
  add_index "physicians_specialities", ["priority"], name: "index_physicians_specialities_on_priority", using: :btree
  add_index "physicians_specialities", ["speciality_id"], name: "index_physicians_specialities_on_speciality_id", using: :btree

  create_table "profiles", force: true do |t|
    t.integer  "user_id"
    t.string   "username"
    t.string   "avatar"
    t.string   "gender"
    t.date     "birthdate"
    t.float    "height"
    t.float    "weight"
    t.string   "pathway"
    t.string   "occupation"
    t.string   "country"
    t.string   "city"
    t.boolean  "network_visible"
    t.string   "income_level"
    t.integer  "condition_ids",                 default: [],  array: true
    t.string   "interests",                     default: [],  array: true
    t.json     "social_friends"
    t.float    "completion",                    default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "education_level"
    t.string   "region"
    t.string   "avatar_tmp"
    t.string   "ios_device_token"
    t.string   "anonymous_username", limit: 50
  end

  add_index "profiles", ["anonymous_username"], name: "index_profiles_on_anonymous_username", using: :btree
  add_index "profiles", ["city"], name: "index_profiles_on_city", using: :btree
  add_index "profiles", ["country"], name: "index_profiles_on_country", using: :btree
  add_index "profiles", ["income_level"], name: "index_profiles_on_income_level", using: :btree
  add_index "profiles", ["occupation"], name: "index_profiles_on_occupation", using: :btree
  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "questions", force: true do |t|
    t.string   "category"
    t.boolean  "is_optional"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "question_type"
    t.json     "options"
  end

  add_index "questions", ["category"], name: "index_questions_on_category", using: :btree
  add_index "questions", ["is_optional"], name: "index_questions_on_is_optional", using: :btree

  create_table "referral_codes", force: true do |t|
    t.string   "code"
    t.string   "memo"
    t.integer  "medical_experiences_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", force: true do |t|
    t.integer  "user_id"
    t.integer  "reportable_id"
    t.string   "reportable_type"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reports", ["user_id"], name: "index_reports_on_user_id", using: :btree

  create_table "reviews", force: true do |t|
    t.integer  "medical_experience_id"
    t.integer  "reviewable_id"
    t.string   "type"
    t.integer  "helpfuls_count",        default: 0
    t.string   "dosage"
    t.string   "intake_frequency"
    t.string   "duration"
    t.string   "adverse_effects"
    t.float    "completion",            default: 0.0
    t.float    "avg_rating",            default: 0.0
    t.text     "note"
    t.string   "status",                default: "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_anonymous",          default: false,     null: false
  end

  add_index "reviews", ["medical_experience_id"], name: "index_reviews_on_medical_experience_id", using: :btree
  add_index "reviews", ["reviewable_id"], name: "index_reviews_on_reviewable_id", using: :btree
  add_index "reviews", ["type"], name: "index_reviews_on_type", using: :btree

  create_table "specialities", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vendor_id"
  end

  create_table "symptoms", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category"
  end

  add_index "symptoms", ["name"], name: "index_symptoms_on_name", using: :btree

  create_table "translations", force: true do |t|
    t.integer  "entity_id"
    t.text     "string"
    t.string   "entity_type"
    t.string   "field_name"
    t.string   "language"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "phone"
    t.string   "email"
    t.string   "password_digest",        default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "mailed_as_new_user",     default: false
    t.boolean  "is_guest",               default: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["phone"], name: "index_users_on_phone", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
