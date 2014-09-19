class RepairSchemaErrors < ActiveRecord::Migration

  # get rescued from hell
  def up
    if Rails.env.production? or Rails.env.staging?
      create_table "metric_badges" do |t|
        t.integer  "metric_id"
        t.integer  "badge_id"
        t.datetime "created_at"
        t.datetime "updated_at"
      end
   
      create_table "shared_earned_badges" do |t|
        t.integer  "course_id"
        t.text     "student_name"
        t.integer  "user_id"
        t.string   "icon"
        t.string   "name"
        t.integer  "badge_id"
        t.datetime "created_at"
        t.datetime "updated_at"
      end
    
      create_table "tier_badges" do |t|
        t.integer  "tier_id"
        t.integer  "badge_id"
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      change_table "assignment_types" do |t|
        t.change :notify_released, :boolean, default: true
        t.boolean  "is_attendance"
        t.boolean  "has_winners"
        t.integer  "num_winner_levels"
      end

      change_column :assignments, :notify_released, :boolean, default: true

      drop_table "duplicated_users"

      add_column :grade_scheme_elements, :team_id, :integer

      change_column :grades, :raw_score, :integer, default: 0

      remove_index "grades", name: "index_grades_on_assignment_id_and_task_id_and_submission_id"

      drop_table "submission_files_duplicate"
    end
  end

  # go back to hell for no reason evident to any human living or otherwise
  def down
    if Rails.env.production? or Rails.env.staging?
      drop_table "metric_badges"
      drop_table "shared_earned_badges"
      drop_table "tier_badges"

      change_table "assignment_types" do |t|
        t.change :notify_released, :boolean
        t.remove "is_attendance"
        t.remove "has_winners"
        t.remove "num_winner_levels"
      end

      change_column :assignments, :notify_released, :boolean, default: true

      create_table "duplicated_users", id: false do |t|
        t.integer "id"
        t.string  "last_name"
        t.string  "role"
        t.integer "submissions", limit: 8
      end

      change_column :grades, :raw_score, :integer, default: 0, null: false

      add_index "grades", ["assignment_id", "task_id", "submission_id"], name: "index_grades_on_assignment_id_and_task_id_and_submission_id", unique: true, using: :btree

      create_table "submission_files_duplicate", id: false, force: true do |t|
        t.string  "key",        limit: nil
        t.string  "format",     limit: nil
        t.integer "upload_id"
        t.string  "full_name",  limit: nil
        t.string  "last_name",  limit: nil
        t.string  "first_name", limit: nil
      end
    end
  end
end
