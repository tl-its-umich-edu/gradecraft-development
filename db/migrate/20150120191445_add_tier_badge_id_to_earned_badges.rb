class AddTierBadgeIdToEarnedBadges < ActiveRecord::Migration
  def change
    add_column :earned_badges, :tier_badge_id, :integer
  end
end
