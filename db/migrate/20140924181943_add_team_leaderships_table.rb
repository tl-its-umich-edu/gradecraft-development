class AddTeamLeadershipsTable < ActiveRecord::Migration
  def change
    create_table :team_leaderships do |t|
      t.integer  "team_id"
      t.integer  "leader_id"
      t.timestamps
    end
  end
end
