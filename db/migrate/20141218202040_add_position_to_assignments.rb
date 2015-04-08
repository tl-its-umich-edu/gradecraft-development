class AddPositionToAssignments < ActiveRecord::Migration
  def change
  	add_column :assignments, :position, :integer
  end
end
