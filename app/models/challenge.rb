class Challenge < ActiveRecord::Base

  attr_accessible :name, :description, :icon, :visible, :image_file_name, :occurrence,
    :value, :multiplier, :point_total, :due_at, :open_at, :accepts_submissions, 
    :release_necessary, :course, :team, :challenge, :challenge_file_ids, 
    :challenge_files_attributes, :challenge_file, :challenge_grades_attributes, 
    :challenge_score_levels_attributes, :challenge_score_level

  belongs_to :course
  has_many :submissions
  has_many :challenge_grades
  has_many :challenge_score_levels
  accepts_nested_attributes_for :challenge_score_levels, allow_destroy: true, :reject_if => proc { |a| a['value'].blank? || a['name'].blank? }
  
  has_many :challenge_files, :dependent => :destroy
  accepts_nested_attributes_for :challenge_files
  accepts_nested_attributes_for :challenge_grades

  validates_presence_of :course, :name
  validate :positive_points, :open_before_close

  scope :chronological, -> { order('due_at ASC') }
  scope :alphabetical, -> { order('name ASC') }

  def has_levels?
    levels == true
  end

  def mass_grade?
    mass_grade = true
  end

  def challenge_grades_by_team_id
    @challenge_grade_for_team ||= challenge_grades.group_by(&:team_id)
  end

  def challenge_grade_for_team(team)
    challenge_grades_by_team_id[team.id].try(:first)
  end

  def challenge_submissions_by_team_id
    @challenge_submissions_by_team ||= challenge_submissions.group_by(&:team_id)
  end

  def challenge_submission_for_team(team)
    challenge_submissions_by_team_id[team.id].try(:first)
  end

  def future?
    due_at != nil && due_at >= Date.today
  end

  def graded?
    challenge_grades.present?
  end

  private

  def open_before_close
    if (due_at? && open_at?) && (due_at < open_at)
      errors.add :base, 'Due date must be after open date.'
    end
  end

  def positive_points
    if point_total? && point_total < 1
      errors.add :base, 'Point total must be a positive number'
    end
  end

end