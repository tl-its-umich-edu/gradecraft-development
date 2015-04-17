class Tier < ActiveRecord::Base
  belongs_to :metric
  has_many :tier_badges
  has_many :badges, through: :tier_badges
  has_many :rubric_grades

  validates :points, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :name, presence: true, length: { maximum: 30 }

  attr_accessible :name, :description, :points, :metric_id, :durable, :full_credit, :no_credit, :sort_order

  include DisplayHelpers

end
