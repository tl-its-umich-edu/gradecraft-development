class RubricGrade < ActiveRecord::Base
  belongs_to :submission
  belongs_to :metric
  belongs_to :tier
  belongs_to :student
  belongs_to :assignment
  # has_many :earned_badges, dependent: :destroy

  attr_accessible :metric_name, :metric_description, :max_points, :tier_name,
    :tier_description, :points, :submission_id, :metric_id, :tier_id, :order,
    :student_id, :assignment_id, :comments

  validates :max_points, presence: true
  validates :metric_name, presence: true
  validates :order, presence: true
  # validates :tier_name, presence: true
  # validates :points, presence: true
  validates :student_id, presence: true
  validate :submission_or_assignment_present

  # after_create :create_earned_badges

  private

    def submission_or_assignment_present
      submission_id.present? or assignment_id.present?
    end
end
