class AddInstructorModifiedToGrade < ActiveRecord::Migration
  def change
    add_column :grades, :instructor_modified, :boolean, default: false
  end
end
