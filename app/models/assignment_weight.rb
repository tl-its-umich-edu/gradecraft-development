class AssignmentWeight < ActiveRecord::Base
  attr_accessible :student, :student_id, :assignment, :assignment_id, :weight

  include Canable::Ables

  belongs_to :student, :class_name => 'User', touch: true
  belongs_to :assignment_type
  belongs_to :assignment, touch: true
  belongs_to :course
  belongs_to :submission

  before_validation :cache_associations, :cache_point_total
  #after_save :save_grades, :save_student

  validates_presence_of :student, :assignment, :assignment_type, :course

  # validate :course_total_assignment_weight_not_exceeded, :course_max_assignment_weight_not_exceeded

  scope :except_weight, ->(weight) { where('assignment_weights.id != ?', weight.id) }
  scope :for_course, ->(course) { where(:assignment_id => course.assignments.pluck(:id)) }

  #delegate :course, :to => :assignment, :allow_nil => false

  def self.weight
    limit(1).pluck(:weight).first || 0
  end

  def updatable_by?(user)
    self.student_id == student.id
  end

  def destroyable_by?(user)
    updatable_by?(user)
  end

  def viewable_by?(user)
    updatable_by?(user)
  end

  def course_total_assignment_weight
    course.assignment_weight_for_student(student) + (persisted? ? 0 : weight)
  end

  private

  def course_total_assignment_weight_not_exceeded
    if course_total_assignment_weight > course.total_assignment_weight
      errors.add :base, "Please select a lower #{course.weight_term.downcase}"
    end
  end

  def course_max_assignment_weight_not_exceeded
    if course.max_assignment_weight? 
      if weight > course.max_assignment_weight
        errors.add :base, "Please select a lower #{course.weight_term.downcase} value"
      end
    end
  end

  def cache_associations
    self.assignment_type_id ||= assignment.try(:assignment_type_id)
    self.course_id ||= assignment.try(:course_id)
  end

  def cache_point_total
    self.point_total = assignment.point_total_for_student(student, weight)
  end
  #TODO: pending refactoring
  def save_grades
    assignment.grades.where(student: student).each(&:save)
  end

  def save_student
    student.save
  end
end
