class AddUniqueIndexToGrades < ActiveRecord::Migration
  def change
    add_index :grades, [:assignment_id, :student_id], unique: true
  end
end
