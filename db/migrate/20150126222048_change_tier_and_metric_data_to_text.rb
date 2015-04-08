class ChangeTierAndMetricDataToText < ActiveRecord::Migration
  def up
    change_column :rubric_grades, :tier_description, :text
    change_column :rubric_grades, :metric_description, :text
  end

  def down
    change_column :rubric_grades, :tier_description, :string
    change_column :rubric_grades, :metric_description, :string
  end
end
