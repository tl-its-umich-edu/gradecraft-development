class ChangeEventNames < ActiveRecord::Migration
  def change
    rename_column :events, :open_date, :open_at
    rename_column :events, :close_date, :due_at
  end
end
