class ChallengeGrade < ActiveRecord::Base

  attr_accessible :name, :course_id, :rank, :score, :challenge_id, :text_feedback, :status, :team_id, :final_score, :status, :team, :challenge

  belongs_to :course
  belongs_to :challenge
  belongs_to :team, :autosave => true
  belongs_to :submission # Optional
  belongs_to :task # Optional

  after_save :cache_team_score

  validates_presence_of :team, :challenge

  delegate :name, :description, :due_at, :point_total, :to => :challenge

  def score
    super.presence || 0
  end

  def cache_team_score 
    team.save!
  end

end
