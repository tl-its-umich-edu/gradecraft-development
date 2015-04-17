class AddAcceptsFormatsToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :accepts_attachments, :boolean, :default => true
    add_column :assignments, :accepts_text, :boolean, :default => true
    add_column :assignments, :accepts_links, :boolean, :default => true
  end
end
