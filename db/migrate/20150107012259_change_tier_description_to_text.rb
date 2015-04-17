class ChangeTierDescriptionToText < ActiveRecord::Migration
  def up
    change_column :tiers, :description, :text
  end

  def down
    change_column :tiers, :description, :string
  end
end
