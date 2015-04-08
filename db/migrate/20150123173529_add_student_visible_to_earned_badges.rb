class AddStudentVisibleToEarnedBadges < ActiveRecord::Migration
  def change
    add_column :earned_badges, :student_visible, :boolean, default: true
  end
end
