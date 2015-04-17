class AddStudentLoggedButtonTextToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :student_logged_button_text, :string
    add_column :assignments, :student_logged_revert_button_text, :string
  end
end
