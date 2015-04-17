class AddMetricIdToEarnedBadges < ActiveRecord::Migration
  def change
    add_column :earned_badges, :metric_id, :integer
  end
end
