class Submission < ActiveRecord::Base
  attr_accessible :task, :task_id, :assignment, :assignment_id, :assignment_type_id, :comment,
    :feedback, :group, :group_id, :attachment, :link, :student, :student_id,
    :creator, :creator_id, :text_feedback, :text_comment, :graded, :submission_file, :submission_files_attributes, :submission_files,
    :course_id, :submission_file_ids, :updated_at

  include Canable::Ables

  belongs_to :task
  belongs_to :assignment
  belongs_to :student, :class_name => 'User'
  belongs_to :creator, :class_name => 'User'
  belongs_to :group
  belongs_to :course

  before_save :clean_html, :submit_something

  has_one :grade, :dependent => :destroy
  has_one :assignment_weight, through: :assignment
  has_many :rubric_grades, dependent: :destroy

  accepts_nested_attributes_for :grade
  has_many :submission_files, :dependent => :destroy, autosave: true
  accepts_nested_attributes_for :submission_files

  scope :ungraded, -> { where('NOT EXISTS(SELECT 1 FROM grades WHERE submission_id = submissions.id OR (assignment_id = submissions.assignment_id AND student_id = submissions.student_id) AND (status = ? OR status = ?))', "Graded", "Released") }
  scope :graded, -> { where(:grade) }
  scope :resubmitted, -> { where('EXISTS(SELECT 1 FROM grades WHERE (assignment_id = submissions.assignment_id AND student_id = submissions.student_id) AND (updated_at < submissions.updated_at) AND (status = ? OR status = ?))', "Graded", "Released") }


  before_validation :cache_associations

  validates_uniqueness_of :task, :scope => :student, :allow_nil => true
  validates_uniqueness_of :assignment_id, { :scope => :student_id }
  validates :link, :format => URI::regexp(%w(http https)) , :allow_blank => true

  #Canable permissions#
  def updatable_by?(user)
    if assignment.is_individual?
      student_id == user.id
    elsif assignment.has_groups?
      group_id == user.group_for_assignment(assignment).id
    end
  end

  def destroyable_by?(user)
    if assignment.is_individual?
      student_id == user.id || user.is_staff?(current_course)
    elsif assignment.has_groups?
      group_id == user.group_for_assignment(assignment).id
    end
  end

  # Grabbing any submission that has NO instructor-defined grade (if the student has predicted the grade,
  # it'll exist, but we still don't want to catch those here)
  def ungraded?
    ! grade || grade.status == nil
  end

  def resubmitted?
    student.grade_for_assignment(assignment).present? && student.grade_for_assignment(assignment).updated_at < self.updated_at
  end


  #Permissions regarding who can see a grade
  def viewable_by?(user)
    if assignment.is_individual?
      student_id == user.id
    elsif assignment.has_groups?
      group_id == user.group_for_assignment(assignment).id
    end
  end

  #Grading status
  def status
    if grade
      "Graded"
    else
      "Ungraded"
    end
  end

  # Getting the name of the student who submitted the work
  def name
    student.name
  end

  # Checking to see if a submission was turned in late
  def late?
    created_at > self.assignment.due_at if self.assignment.due_at.present?
  end

  def has_multiple_components?
    return true if (submission_files.count > 1) || (submission_files.present? && (link.present? || text_comment.present?))
    false
  end

  private

  def clean_html
    self.text_comment = Sanitize.clean(text_comment, Sanitize::Config::RESTRICTED)
  end

  def submit_something
    link.present? || text_comment.present? || submission_files.present?
  end

  def cache_associations
    if task
      self.assignment_id ||= task.assignment_id
      self.assignment_type ||= task.assignment_type
      self.course_id ||= task.assignment.course_id
    end
    self.assignment_id ||= assignment.id
    self.assignment_type ||= assignment.assignment_type
    self.course_id ||= assignment.course_id
  end
end
