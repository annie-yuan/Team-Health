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

ActiveRecord::Schema.define(version: 2022_03_29_152050) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.string "course_name"
    t.string "course_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "admin_id"
    t.index ["admin_id"], name: "index_courses_on_admin_id"
  end

  create_table "courses_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
  end

  create_table "feedbacks", force: :cascade do |t|
    t.float "rating", null: false
    t.string "comments", limit: 2048
    t.datetime "timestamp", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "team_id"
    t.bigint "user_id"
    t.integer "priority", default: 2, null: false
    t.integer "collaboration_score"
    t.integer "communication_score"
    t.integer "time_management_score"
    t.integer "problem_solving_score"
    t.integer "knowledge_of_roles_score"
    t.index ["team_id"], name: "index_feedbacks_on_team_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "join_team_statuses", force: :cascade do |t|
    t.bigint "team_id"
    t.bigint "user_id"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["team_id"], name: "index_join_team_statuses_on_team_id"
    t.index ["user_id"], name: "index_join_team_statuses_on_user_id"
  end

  create_table "options", force: :cascade do |t|
    t.boolean "reports_toggled", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "admin_code", limit: 10, default: "admin"
  end

  create_table "reports", force: :cascade do |t|
    t.integer "reporter_id", null: false
    t.integer "reportee_id", null: false
    t.string "description", limit: 2048
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "priority", default: 2, null: false
    t.index ["reportee_id"], name: "index_reports_on_reportee_id"
    t.index ["reporter_id"], name: "index_reports_on_reporter_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "team_code"
    t.string "team_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "course_id"
    t.index ["course_id"], name: "index_teams_on_course_id"
    t.index ["team_code"], name: "index_teams_on_team_code", unique: true
    t.index ["team_name", "course_id"], name: "index_teams_on_team_name_and_course_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 255, null: false
    t.string "first_name", null: false
    t.boolean "is_admin", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "password_digest"
    t.string "last_name", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "courses", "users", column: "admin_id"
  add_foreign_key "feedbacks", "teams"
  add_foreign_key "feedbacks", "users", on_delete: :cascade
  add_foreign_key "reports", "users", column: "reportee_id", on_delete: :cascade
  add_foreign_key "reports", "users", column: "reporter_id", on_delete: :cascade
  add_foreign_key "teams", "courses"
end
