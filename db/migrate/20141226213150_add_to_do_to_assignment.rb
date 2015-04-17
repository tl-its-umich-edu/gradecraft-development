class AddToDoToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :include_in_to_do, :boolean, :default => true
  end
end
