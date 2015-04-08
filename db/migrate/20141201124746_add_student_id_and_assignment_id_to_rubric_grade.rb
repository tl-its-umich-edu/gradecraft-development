class AddStudentIdAndAssignmentIdToRubricGrade < ActiveRecord::Migration
  def change
    add_column :rubric_grades, :assignment_id, :integer
    add_column :rubric_grades, :student_id, :integer
  end
end
