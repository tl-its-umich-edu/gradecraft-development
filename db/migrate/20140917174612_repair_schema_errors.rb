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

      add_column :grade_scheme_elements, :team_id, :integer

      change_column :grades, :raw_score, :integer, default: 0

    end
  end

  # go back to hell for no reason evident to any human living or otherwise
  def down
    if Rails.env.production? or Rails.env.staging?
      drop_table "metric_badges"
      drop_table "tier_badges"

      change_table "assignment_types" do |t|
        t.change :notify_released, :boolean
        t.remove "is_attendance"
        t.remove "has_winners"
        t.remove "num_winner_levels"
      end

      change_column :assignments, :notify_released, :boolean, default: true

      change_column :grades, :raw_score, :integer, default: 0, null: false
    end
  end
end
