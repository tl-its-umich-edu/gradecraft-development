class AssignmentsUseRubricsByDefault < ActiveRecord::Migration
  def up
    change_column :assignments, :use_rubric, :boolean, default: true
  end

  def down
    change_column :assignments, :use_rubric, :boolean, default: false
  end
end
