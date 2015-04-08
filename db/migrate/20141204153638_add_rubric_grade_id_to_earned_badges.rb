class AddRubricGradeIdToEarnedBadges < ActiveRecord::Migration
  def change
    add_column :earned_badges, :rubric_grade_id, :integer
  end
end
