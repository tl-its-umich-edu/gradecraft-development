class ChangeDescriptionEvent < ActiveRecord::Migration
  def change
    rename_column :events, :descripton, :description
  end
end
