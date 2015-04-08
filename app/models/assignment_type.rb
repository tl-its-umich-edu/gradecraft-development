class AssignmentType < ActiveRecord::Base
  acts_as_list scope: :course
  
  attr_accessible :due_date_present, :levels, :max_value, :name,
    :percentage_course, :point_setting, :points_predictor_display,
    :predictor_description, :resubmission, :universal_point_value, :order_placement, 
    :student_weightable, :mass_grade, :score_levels_attributes, :score_level, :mass_grade_type, 
    :student_logged_revert_button_text, :student_logged_button_text, :position

  belongs_to :course
  has_many :assignments, -> { order('position ASC') }
  has_many :submissions, :through => :assignments
  has_many :assignment_weights
  has_many :grades
  has_many :score_levels, -> { order "value" }
  accepts_nested_attributes_for :score_levels, allow_destroy: true, :reject_if => proc { |a| a['value'].blank? || a['name'].blank? }

  validates_presence_of :name
  validate :positive_universal_value, :positive_max_points
  before_save :ensure_score_levels, :if => :multi_select?

  scope :student_weightable, -> { where(:student_weightable => true) }
  scope :timelinable, -> { where(:include_in_timeline => true) }
  scope :todoable, -> { where(:include_in_to_do => true) }
  scope :predictable, -> { where(:include_in_predictor => true) }
  scope :sorted, -> { order 'position' }
  scope :weighted_for_student, ->(student) { joins("LEFT OUTER JOIN assignment_weights ON assignment_types.id = assignment_weights.assignment_type_id AND assignment_weights.student_id = '#{sanitize student.id}'") }

  def self.weights_for_student(student)
    group('assignment_types.id').weighted_for_student(student).pluck('assignment_types.id, COALESCE(MAX(assignment_weights.weight), 0)')
  end

  def weight_for_student(student)
    return 1 unless student_weightable?
    assignment_weights.where(student: student).weight
  end

  #These determine how assignment types appears in the predictor
  def slider?
    points_predictor_display == "Slider"
  end

  def fixed?
    points_predictor_display == "Fixed"
  end

  def select?
    points_predictor_display == "Select List"
  end

  def per_assignment?
    points_predictor_display == "Set per Assignment"
  end

  def has_predictable_assignments?
    assignments.any?(&:include_in_predictor?)
  end

  #Checks if the assignment type has associated score levels
  def has_levels?
    score_levels.present?
  end

  #Powers the To Do list, checks if there are assignments within the next week (soon is a scope in the Assignment model)
  def has_soon_assignments?
    assignments.any?(&:soon?)
  end

  #Determines how the assignment type is handled in Quick Grade
  def grade_checkboxes?
    mass_grade_type == "Checkbox"
  end

  def grade_select?
    mass_grade_type == "Select List"
  end

  def grade_radio?
    mass_grade_type == "Radio Buttons"
  end

  def grade_text?
    mass_grade_type == "Text"
  end

  # Check to see if the assignment type needs score levels to be present for grading purposes
  def multi_select?
    grade_select? || grade_radio?
  end

  def grade_per_assignment?
    mass_grade_type == "Set per Assignment"
  end

  #Getting the assignment types max value if it's present, else summing all it's assignments to create the total
  def max_value
    super.presence || assignments.map{ |a| a.point_total }.sum
  end

  def score_for_student(student)
    student.grades.released.where(:assignment_type => self).pluck('score').sum
  end

  def raw_score_for_student(student)
    student.grades.where(:assignment_type => self).pluck('raw_score').sum
  end

  def export_scores
    if student_weightable?
      CSV.generate do |csv|
        csv << ["First Name", "Last Name", "Username", "Raw Score", "Multiplied Score" ]
        course.students.each do |student|
          csv << [student.first_name, student.last_name, student.email, self.raw_score_for_student(student), self.score_for_student(student)]
        end
      end
    else
      CSV.generate do |csv|
        csv << ["First Name", "Last Name", "Username", "Raw Score" ]
        course.students.each do |student|
          csv << [student.first_name, student.last_name, student.email, self.raw_score_for_student(student)]
        end
      end
    end
  end

  private

  def positive_universal_value
    if universal_point_value? && universal_point_value < 1
      errors.add :base, "Point value must be a positive number."
    end
  end

  def positive_max_points
    if max_value? && max_value < 1
      errors.add :base, "Maximum points must be a positive number."
    end
  end

  #Checking to make sure there are score levels and warning if not
  def ensure_score_levels
    if score_levels.count <= 2
      errors.add :base, "To use the selected method of quick grading you must create at least 2 score levels."
    end
  end
end
