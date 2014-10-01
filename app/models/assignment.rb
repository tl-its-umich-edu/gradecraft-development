class Assignment < ActiveRecord::Base
  attr_accessible :name, :description, :point_total, :open_at, :due_at, :grade_scope, :visible, :required, 
    :accepts_submissions, :release_necessary, :media, :thumbnail, :media_credit, :media_caption, 
    :accepts_submissions_until, :points_predictor_display, :notify_released, :mass_grade_type, :assignment_type_id,
    :include_in_timeline, :include_in_predictor, :grades_attributes, :assignment_file_ids, :student_logged,
    :assignment_files_attributes, :assignment_file, :assignment_score_levels_attributes, :assignment_score_level, :score_levels_attributes

  belongs_to :course
  belongs_to :assignment_type, -> { order('order_placement ASC') }
  has_one :rubric
  delegate :mass_grade?, :student_weightable?, :to => :assignment_type

  #For instances where the assignment inherits the score levels through the assignment type
  has_many :score_levels, :through => :assignment_type

  #for instances where the assignment needs its own unique score levels
  has_many :assignment_score_levels
  accepts_nested_attributes_for :assignment_score_levels, allow_destroy: true, :reject_if => proc { |a| a['value'].blank? || a['name'].blank? }
  
  #This is the assignment weighting system (students decide how much assignments will be worth for them)
  has_many :weights, :class_name => 'AssignmentWeight'

  #Student created groups, can connect to multiple assignments and receive group level or individualized feedback
  has_many :assignment_groups
  has_many :groups, :through => :assignment_groups

  # Multipart assignments
  has_many :tasks, :as => :assignment, :dependent => :destroy

  # Student created submissions to be graded
  has_many :submissions, as: :assignment

  has_many :grades, :dependent => :destroy
  accepts_nested_attributes_for :grades, :reject_if => Proc.new { |attrs| attrs[:raw_score].blank? }

  has_many :users, :through => :grades

  # Mike, pretty sure these are old, okay if we delete?
  #has_many :assignment_rubrics, dependent: :destroy
  #accepts_nested_attributes_for :assignment_rubrics, allow_destroy: true
  #has_many :rubrics, through: :assignment_rubrics, dependent: :destroy
  
  #Instructor uploaded resource files
  has_many :assignment_files, :dependent => :destroy
  accepts_nested_attributes_for :assignment_files

  has_many :assignment_weights

  #Preventing malicious content from being submitted
  before_save :clean_html

  #Saving the course and the point total if possible 
  before_validation :cache_point_total
  
  # Longterm we may want to do more to resave grades if an assignment score total changed
  after_save :save_weights

  # Check to make sure the assignment has a name before saving 
  validates :name, presence: true

  #Check to make sure the assignment has an assignment type before saving
  validates :assignment_type_id, presence: true

  # Filtering Assignments by Team Work, Group Work, and Individual Work
  scope :individual_assignments, -> { where grade_scope: "Individual" }
  scope :group_assignments, -> { where grade_scope: "Group" }
  scope :team_assignments, -> { where grade_scope: "Team" }

  # Filtering Assignments by where in the interface they are displayed
  scope :timelineable, -> { where(:include_in_timeline => true) }
  scope :predictable, -> { where(:include_in_predictor => true) }

  # Invisible Assignments are displayed on the instructor side, but not students (until they have a grade for them)
  scope :visible, -> { where visible: TRUE }

  # Sorting assignments by different properties
  scope :chronological, -> { order('due_at ASC') }
  scope :alphabetical, -> { order('name ASC') }

  # Filtering Assignments by various date properties
  scope :with_due_date, -> { where('assignments.due_at IS NOT NULL') }
  scope :without_due_date, ->  { where('assignments.due_at IS NULL') }
  scope :future, -> { with_due_date.where('assignments.due_at >= ?', Time.now) }
  scope :still_accepted, -> { with_due_date.where('assignments.accepts_submissions_until >= ?', Time.now) }
  scope :past, -> { with_due_date.where('assignments.due_at < ?', Time.now) }

  # Assignments and Grading
  scope :graded_for_student, ->(student) { where('EXISTS(SELECT 1 FROM grades WHERE assignment_id = assignments.id AND (status = ?) OR (status = ? AND NOT assignments.release_necessary) AND (assignments.due_at < NOW() OR student_id = ?))', 'Released', 'Graded', student.id) }
  scope :weighted_for_student, ->(student) { joins("LEFT OUTER JOIN assignment_weights ON assignments.id = assignment_weights.assignment_id AND assignment_weights.student_id = '#{sanitize student.id}'") }

  scope :released, ->(student) { where('EXISTS (SELECT 1 FROM released_grades WHERE ((released_grades.assignment_id = assignments.id) AND (released_grades.student_id = ?)))', student.id) }

  def to_json(options = {})
    super(options.merge(:only => [ :id, :content, :order, :done ] ))
  end

  #Used to sum the total number of assignment points in the class
  def self.point_total
    pluck('COALESCE(SUM(assignments.point_total), 0)').first || 0
  end

  def self.assignment_type_point_totals_for_student(student)
    group('assignments.assignment_type_id').weighted_for_student(student).pluck('assignments.assignment_type_id, COALESCE(SUM(COALESCE(assignment_weights.point_total, assignments.point_total)), 0)')
  end

  def self.point_totals_for_student(student)
    weighted_for_student(student).pluck('assignments.id, COALESCE(assignment_weights.point_total, assignments.point_total)')
  end

  def self.point_total_for_student(student)
    weighted_for_student(student).pluck('SUM(COALESCE(assignment_weights.point_total, assignments.point_total))').first || 0
  end

  def self.with_assignment_weights_for_student(student)
    joins("LEFT OUTER JOIN assignment_weights ON assignments.id = assignment_weights.assignment_id AND assignment_weights.student_id = '#{sanitize student.id}'").select('assignments.*, COALESCE(assignment_weights.point_total, assignments.point_total) AS student_point_total')
  end

  def grades_for_assignment(student)
    user_score = grades.where(:student_id => student.id).first.try(:raw_score)
    scores = grades.graded.pluck('raw_score')
    return {
    :scores => scores,
    :user_score => user_score
   }
  end

  #Basic result stats - high, low, average, median
  def high_score
    grades.graded.maximum('grades.raw_score')
  end

  def low_score
    grades.graded.minimum('grades.raw_score')
  end

  #average of all grades for an assignment
  def average
    grades.graded.average('grades.raw_score').to_i if grades.graded.present?
  end

  def has_rubric?
    !! rubric
  end

  def fetch_or_create_rubric
    return rubric if rubric
    Rubric.create assignment_id: self[:id]
  end

  def ungraded_submissions
    submissions.where("id not in (select submission_id from rubric_grades)")
  end

  #average of above-zero grades for an assignment
  def earned_average
    if grades.graded.present?
      grades.graded.where("score > 0").average('score').to_i
    else
      0
    end
  end

  def median
    sorted_grades = grades.graded.pluck('score').sort
    len = sorted_grades.length
    return (sorted_grades[(len - 1) / 2] + sorted_grades[len / 2]) / 2.0
  end

  #Checking to see if an assignment is individually graded 
  def is_individual?
    !['Group'].include? grade_scope
  end

  #Checking to see if the assignment is a group assignment
  def has_groups?
    grade_scope=="Group"
  end

  #If the point value is set at the assignment type level, grab it from there (commonly used for things like Attendance)
  def point_total
    super || assignment_type.universal_point_value || 0
  end

  #Custom point total if the class has weighted assignments
  def point_total_for_student(student, weight = nil)
    (point_total * weight_for_student(student, weight)).round
  end

  #Grabbing a student's set weight for the assignment - returns one if the course doesn't have weights
  def weight_for_student(student, weight = nil)
    return 1 unless student_weightable?
    weight ||= (weights.where(student: student).pluck('weight').first || 0)
    weight > 0 ? weight : default_weight
  end

  #Allows instructors to set a value (presumably less than 1) that would be multiplied by *not* weighted assignments
  def default_weight
    course.default_assignment_weight
  end

  #Getting a student's grade object for an assignment
  def grade_for_student(student)
    grades.graded.where(student_id: student).first
  end

  #Getting a student's score for an assignment
  def score_for_student(student)
    grades.graded.where(student_id: student).pluck('score').first
  end

  #Getting a student's released score for an assignment
  def released_score_for_student(student)
    grades.released.where(student: student).pluck('score').first
  end

  #Get a grade object for a student if it exists - graded or not. this is used in the import grade
  def all_grade_statuses_grade_for_student(student)
    grades.where(student_id: student).first
  end

  #Checking to see if an assignment's due date is past
  def past?
    due_at != nil && due_at < Time.now
  end

  #Checking to see if an assignment's due date is in the future
  def future?
    due_at != nil && due_at >= Time.now
  end

  #Checking to see if an assignment is still accepted - there's often a grey space between due and no longer accepted
  def still_accepted?
    (accepts_submissions_until.present? && accepts_submissions_until >= Time.now) || (accepts_submissions_until == nil)
  end

  #Checking to see if the assignment has submissions that don't have grades
  def has_ungraded_submissions?
    has_submissions == true && submissions.try(:ungraded)
  end

  #Checking to see if an assignment is due soon
  def soon?
    if due_at?
      Time.now <= due_at && due_at < (Time.now + 7.days)
    end
  end

  #Setting the grade predictor displays
  def fixed?
    points_predictor_display == "Fixed"
  end

  def slider?
    points_predictor_display == "Slider"
  end

  def select?
    points_predictor_display == "Select List"
  end
  
  #The below four are the Quick Grading Types, can be set at either the assignment or assignment type level
  def grade_checkboxes?
    assignment_type.mass_grade_type == "Checkbox" || self.mass_grade_type == "Checkbox"
  end

  def grade_select?
    (assignment_type.mass_grade_type == "Select List" && assignment_type.score_levels.present?) || (self.mass_grade_type == "Select List" && self.assignment_score_levels.present?)
  end

  def grade_radio?
    (assignment_type.mass_grade_type == "Radio Buttons" && assignment_type.score_levels.present?) ||(self.mass_grade_type == "Radio Buttons" && self.assignment_score_levels.present?)
  end

  def grade_text?
    assignment_type.mass_grade_type == "Text" || self.mass_grade_type == "Text"
  end

  #Checking to see if an assignment has related score levels
  def has_levels?
   self.assignment_score_levels.present?
  end

  #Finding what grade level was earned for a particular assignment
  def grade_level(grade)
    score_levels.each do |score_level|
      return score_level.name if grade.raw_score == score_level.value
    end
    nil
  end

  #Using the parent assignment type's score levels if they're present - otherwise getting the assignment score levels
  def score_levels_set
    if assignment_type.score_levels.present?
      assignment_type.score_levels
    elsif self.assignment_score_levels.present?
      assignment_score_levels
    end
  end

  #Checking to see if the assignment is still open and accepting submissons
  def open?
    ((open_at != nil && open_at < Time.now) && (due_at != nil && due_at > Time.now)) || due_at.nil?
  end

  #Counting how many grades there are for an assignment
  def grade_count
    grades.graded.count
  end

  #Counting how many non-zero grades there are for an assignment
  def positive_grade_count
    grades.graded.where("score > 0").count
  end

  #Calculating attendance rate, which tallies number of people who have positive grades for attendance divided by the total number of students in the class
  def completion_rate(course)
   ((grade_count / course.graded_student_count.to_f) * 100).round(2)
  end

  def submission_rate(course)
    ((submissions.count / course.graded_student_count.to_f) * 100).round(2)
  end

  def group_submission_rate
    ((submissions.count / groups.count.to_f) * 100).round(2)
  end

  #Calculates attendance rate as an integer.
   def attendance_rate_int(course)
   ((positive_grade_count / course.graded_student_count.to_f) * 100).to_i
  end

  #single assignment gradebook
  def gradebook_for_assignment(assignment, options = {})
    CSV.generate(options) do |csv|
      csv << ["First Name", "Last Name", "Uniqname", "Score", "Statement", "Feedback" ]
      course.students.each do |student|
        csv << [student.first_name, student.last_name, student.username, student.grade_for_assignment(assignment).score, student.submission_for_assignment(assignment).try(:text_comment), student.grade_for_assignment(assignment).try(:feedback) ]
      end
    end
  end

  def email_based_grade_import(assignment, options = {})
    CSV.generate(options) do |csv|
      csv << ["First Name", "Last Name", "Email", "Score"]
      course.students.each do |student|
        csv << [student.first_name, student.last_name, student.email, student.grade_for_assignment(assignment).try(:score)]
      end
    end
  end

  def username_based_grade_import(assignment, options = {})
    CSV.generate(options) do |csv|
      csv << ["First Name", "Last Name", "Email", "Score"]
      course.students.each do |student|
        csv << [student.first_name, student.last_name, student.username, student.grade_for_assignment(assignment).try(:score)]
      end
    end
  end

  def name_based_grade_import(assignment, options = {})
    CSV.generate(options) do |csv|
      csv << ["Student", "ID", "Section", assignment.name]
      csv << ["    Points Possible", "", "", assignment.point_total]
      course.students.each do |student|
        csv << [student.last_name + ", " + student.first_name, student.id, student.team_for_course(course).try(:name), student.grade_for_assignment(assignment).try(:score)]
      end
    end
  end

  # Calculating how many of each score exists
  def score_count
    Hash[grades.graded.group_by{ |g| g.score }.map{ |k, v| [k, v.size] }]
  end

  # Calculating how many of each score exists
  def earned_score_count
    Hash[grades.graded.group_by{ |g| g.raw_score }.map{ |k, v| [k, v.size ] }]
  end

  def earned_scores
    scores = []
    earned_score_count.each do |score|
      scores << { :data => score[1], :name => score[0] }
    end
    return {
      :scores => scores
    }
  end

  # Creating an array with the set of scores earned on the assignment, and 
  def percentage_score_earned
    scores = []
    earned_score_count.each do |score|
      scores << { :data => score[1], :name => score[0] }
    end
    return {
      :scores => scores
    }
  end

  private

  #Stripping the description of extra code
  def clean_html
    self.description = Sanitize.clean(description, Sanitize::Config::BASIC)
  end

  #Getting the point total from the assignment type if it's present
  def cache_point_total
    if assignment_type.present?
      self.point_total = point_total
    end
  end

  # Checking to see if the assignment point total has altered, and if it has resaving weights
  def save_weights
    if self.point_total_changed?
      weights.reload.each(&:save)
    end
  end
end
