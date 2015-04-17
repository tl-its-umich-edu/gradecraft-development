class AddCommentToRubricGrade < ActiveRecord::Migration
  def change
    add_column :rubric_grades, :comments, :text
  end
end
