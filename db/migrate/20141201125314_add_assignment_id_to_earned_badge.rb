class AddAssignmentIdToEarnedBadge < ActiveRecord::Migration
  def change
    add_column :earned_badges, :assignment_id, :integer
  end
end
