class AddPositionToBadges < ActiveRecord::Migration
  def change
  	add_column :badges, :position, :integer
  end
end
