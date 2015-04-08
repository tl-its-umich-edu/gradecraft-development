class AddTierIdToEarnedBadges < ActiveRecord::Migration
  def change
    add_column :earned_badges, :tier_id, :integer
  end
end
