class AddUseRubricToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :use_rubric, :boolean, default: false
  end
end
