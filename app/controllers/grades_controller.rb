class GradesController < ApplicationController
  respond_to :html, :json
  before_filter :set_assignment, only: [:show, :edit, :update, :destroy, :submit_rubric]
  before_filter :ensure_staff?, :except => [:self_log, :show, :predict_score]
  before_filter :ensure_student?, only: [:predict_score]

  def show
    @assignment = current_course.assignments.find(params[:assignment_id])
    if @assignment.rubric.present?
      @rubric = @assignment.rubric
      @metrics = @rubric.metrics
      @rubric_grades = serialized_rubric_grades

      @viewable_rubric_grades = RubricGrade.joins("left outer join submissions on submissions.id = rubric_grades.submission_id").where(student_id: current_student.id).where(assignment_id: params[:assignment_id])
      @comments_by_metric_id = @viewable_rubric_grades.inject({}) do |memo, rubric_grade|
        memo.merge(rubric_grade.metric_id => rubric_grade.comments)
      end
    end

    if current_user_is_student?
      redirect_to @assignment
    end
    if @assignment.has_groups?
      @group = current_student.group_for_assignment(@assignment)
      @title = "#{@group.name}'s Grade for #{ @assignment.name }"
      @grades_for_assignment = @assignment.grades.graded_or_released
    else
      @title = "#{current_student.name}'s Grade for #{ @assignment.name }"
      @grades_for_assignment = @assignment.grades_for_assignment(current_student)
    end
  end

  def edit
    session[:return_to] = request.referer
    redirect_to @assignment and return unless current_student.present?
    @grade = current_student_data.grade_for_assignment(@assignment)
    @student = @grade.student
    @submission = @student.submission_for_assignment(@assignment)
    @title = "Editing #{current_student.name}'s Grade for #{@assignment.name}"
    if @assignment.rubric.present?
      @rubric = @assignment.rubric
      @rubric_grades = serialized_rubric_grades
      @metrics = existing_metrics_as_json if @rubric
      @course_badges = serialized_course_badges
    end
    @assignment_score_levels = @assignment.assignment_score_levels.order_by_value
  end

  private

  def serialized_rubric_grades
    ActiveModel::ArraySerializer.new(fetch_rubric_grades, each_serializer: ExistingRubricGradesSerializer).to_json
  end

  def fetch_rubric_grades
    RubricGrade.where(fetch_rubric_grades_params)
  end

  def fetch_rubric_grades_params
    { student_id: params[:student_id], assignment_id: params[:assignment_id], metric_id: existing_metric_ids }
  end

  def existing_metric_ids
    rubric_metrics_with_tiers.collect {|metric| metric[:id] }
  end

  public

  # To avoid duplicate grades, we don't supply a create method. Update will
  # create a new grade if none exists, and otherwise update the existing grade
  def update
    redirect_to @assignment and return unless current_student.present?

    if params[:grade][:grade_files_attributes].present?
      @grade_files = params[:grade][:grade_files_attributes]["0"]["file"]
      params[:grade].delete :grade_files_attributes
    end

    @grade = current_student_data.grade_for_assignment(@assignment)

    if @grade_files
      @grade_files.each do |gf|
        @grade.grade_files.new(file: gf, filename: gf.original_filename[0..49])
      end
    end

    if @grade.update_attributes params[:grade].merge(instructor_modified: true)
      Resque.enqueue(GradeUpdater, [@grade.id]) if @grade.is_released?
      if session[:return_to].present?
        redirect_to session[:return_to]
      else
        redirect_to @assignment
      end
    else
      redirect_to edit_assignment_grade_path(@assignment, @grade), notice: "#{@assignment.name} was not successfully submitted! Please try again."
    end
  end

  def submit_rubric
    if @submission = Submission.where(current_assignment_and_student_ids).first
      @submission.update_attributes(graded: true)
    end

    @grade = Grade.where(student_id: current_student[:id], assignment_id: @assignment[:id]).first

    if @grade
      @grade.update_attributes grade_attributes_from_rubric
    else
      @grade = Grade.create(new_grade_from_rubric_grades_attributes)
    end

    delete_existing_rubric_grades
    create_rubric_grades # create an individual record for each rubric grade

    delete_existing_earned_badges_for_metrics # if earned_badges_exist? # destroy earned_badges where assignment_id and student_id match
    create_earned_tier_badges if params[:tier_badges]# create_earned_tier_badges

    Resque.enqueue(GradeUpdater, [@grade.id]) if @grade.is_released?

    respond_to do |format|
      format.json { render nothing: true }
    end
  end

  private
  def rubric_grades_exist?
    rubric_grades.count > 0
  end

  def rubric_grades
    @rubric_grades ||= RubricGrade.where(assignment_student_metric_params)
  end

  def rubric_grades_by_metric_id
    @rubric_grades_by_metric_id = rubric_grades.inject({}) do |memo, rubric_grade|
      memo[rubric_grade.metric_id] = rubric_grade
      memo
    end
  end

  def update_rubric_grades
    params[:rubric_grades].each do |rubric_grade_params|
      rubric_grades_by_metric_id[rubric_grade_params["metric_id"]].update_attributes rubric_grade_params
    end
  end

  def earned_badges_exist?
    EarnedBadge.where(assignment_student_metric_params).count > 0
  end

  def delete_existing_rubric_grades
    RubricGrade.where(assignment_student_metric_params).delete_all
  end

  def delete_existing_earned_badges_for_metrics
    EarnedBadge.where(assignment_student_metric_params).delete_all
  end

  def existing_earned_badges_by_tier_badge_id
    @existing_earned_tier_badges ||= EarnedBadge.where(student_earned_tier_badge_attrs)
  end

  def student_earned_tier_badge_attrs
    { student_id: params[:student_id], tier_badge_id: existing_tier_badge_ids }
  end

  def assignment_student_metric_params
    { assignment_id: params[:assignment_id], student_id: params[:student_id], metric_id: params[:metric_ids] }
  end

  def create_rubric_grades
    params[:rubric_grades].collect do |rubric_grade|
      RubricGrade.create! rubric_grade.merge(extra_rubric_grade_params)
    end
  end

  def extra_rubric_grade_params
    { submission_id: submission_id,
      assignment_id: @assignment[:id],
      student_id: params[:student_id]
    }
  end

  def create_earned_tier_badges
    EarnedBadge.import(new_earned_tier_badges, :validate => true)
  end

  def existing_earned_badges
  end

  def new_earned_tier_badges
    params[:tier_badges].collect do |tier_badge|
      EarnedBadge.new({
        badge_id: tier_badge["badge_id"],
        submission_id: submission_id,
        course_id: current_course[:id],
        student_id: current_student[:id],
        assignment_id: @assignment[:id],
        tier_id: tier_badge[:tier_id],
        metric_id: tier_badge[:metric_id],
        score: tier_badge[:point_total],
        tier_badge_id: tier_badge[:id],
        student_visible: @grade.is_released?
      })
    end
  end

  def submission_id
    @submission[:id] rescue nil
  end

  def serialized_course_badges
    ActiveModel::ArraySerializer.new(course_badges, each_serializer: CourseBadgeSerializer).to_json
  end

  def course_badges
    @course_badges ||= @assignment.course.badges.visible
  end

  public

  def remove
    @grade = Grade.find(params[:grade_id])
    @grade.raw_score = 0
    @grade.status = nil
    @grade.feedback = nil
    @grade.instructor_modified = false
    @grade.update_attributes(params[:grade])
    redirect_to @grade.assignment, notice: "#{ @grade.student.name}'s #{@grade.assignment.name} grade was successfully deleted."
  end

  def destroy
    redirect_to @assignment and return unless current_student.present?
    @grade = current_student_data.grade_for_assignment(@assignment)
    @grade.destroy

    redirect_to assignment_path(@assignment), notice: "#{ @grade.student.name}'s #{@assignment.name} grade was successfully deleted."
  end

  # Allows students to self log grades for a particular assignment if the instructor has turned that feature on - currently only used to log attendance
  def self_log
    @assignment = current_course.assignments.find(params[:id])
    if @assignment.open?
      @grade = current_student_data.grade_for_assignment(@assignment)
      @grade.raw_score = params[:present] == 'true' ? @assignment.point_total : 0
      @grade.status = "Graded"
      respond_to do |format|
        if @grade.save
          Resque.enqueue(GradeUpdater, [@grade.id])
          #GradeUpdater.perform_async([@grade.id])
          format.html { redirect_to syllabus_path, notice: 'Nice job! Thanks for logging your grade!' }
        else
          format.html { redirect_to syllabus_path, notice: "We're sorry, this grade could not be added." }
        end
      end
    else
      format.html { redirect_to dashboard_path, notice: "We're sorry, this assignment is no longer open." }
    end
  end

  # Students predicting the score they'll get on an assignent using the grade predictor
  def predict_score
    @assignment = current_course.assignments.find(params[:id])
    raise "Cannot set predicted score if grade status is 'Graded' or 'Released'" if current_student_data.grade_released_for_assignment?(@assignment)
    @grade = current_student_data.grade_for_assignment(@assignment)
    @grade.predicted_score = params[:predicted_score]
    respond_to do |format|
      format.json do
        if @grade.save
          render :json => @grade
        else
          render :json => { errors:  @grade.errors.full_messages }, :status => 400
        end
      end
    end
  end

  # Quickly grading a single assignment for all students
  def mass_edit
    @assignment = current_course.assignments.find(params[:id])
    @title = "Quick Grade #{@assignment.name}"
    @assignment_type = @assignment.assignment_type
    @assignment_score_levels = @assignment.assignment_score_levels.order_by_value

    if params[:team_id].present?
      @team = current_course.teams.find_by(team_params)
      @students = current_course.students_being_graded.joins(:teams).where(:teams => team_params) 
      @auditors = current_course.students_auditing.joins(:teams).where(:teams => team_params)           
    else
      @students = current_course.students_being_graded
      @auditors = current_course.students_auditing
    end    

    @grades = Grade.where(student_id: mass_edit_student_ids, assignment_id: @assignment[:id] ).includes(:student,:assignment)
    @auditor_grades = Grade.where(student_id: mass_edit_auditor_ids, assignment_id: @assignment[:id] ).includes(:student,:assignment)

    create_missing_grades # create grade objects for the student/assignment pair unless present

    @grades = @grades.sort_by { |grade| [ grade.student.last_name, grade.student.first_name ] }
    @auditor_grades = @auditor_grades.sort_by { |grade| [ grade.student.last_name, grade.student.first_name ] }
  end

  private

    def team_params
      @team_params ||= params[:team_id] ? { id: params[:team_id] } : {}
    end

    def mass_edit_student_ids      
      @mass_edit_student_ids ||= @students.pluck(:id)
    end

    def mass_edit_auditor_ids
      @mass_edit_auditor_ids ||= @auditors.pluck(:id)
    end

    def no_grade_students
      @no_grade_students ||= @students.where(id: mass_edit_student_ids - @grades.pluck(:student_id))
    end

    def no_grade_auditors
      @no_grade_auditors ||= @auditors.where(id: mass_edit_auditor_ids - @grades.pluck(:student_id))
    end

    def create_missing_student_grades
      no_grade_students.each do |student|
        Grade.create(student: student, assignment: @assignment, graded_by_id: current_user)
      end
    end

    def create_missing_auditor_grades
      no_grade_auditors.each do |student|
        Grade.create(student: student, assignment: @assignment, graded_by_id: current_user)
      end
    end

    def create_missing_grades
      create_missing_student_grades
      create_missing_auditor_grades
    end

  public

  def mass_update
    @assignment = current_course.assignments.find(params[:id])
    if @assignment.update_attributes(params[:assignment])
      grade_ids = []
      @assignment.grades.each do |grade|
        if grade.graded_or_released?
          grade_ids << grade.id
        end
      end
      Resque.enqueue(MultipleGradeUpdater, grade_ids)
      if !params[:team_id].blank?
        redirect_to assignment_path(@assignment, :team_id => params[:team_id])
      else
        respond_with @assignment
      end
    else
      redirect_to mass_grade_assignment_path(id: @assignment.id,team_id:params[:team_id]),  notice: "Oops! There was an error while saving the grades!"
    end
  end

  # Grading an assignment for a whole group
  def group_edit
    @assignment = current_course.assignments.find(params[:id])
    @group = @assignment.groups.find(params[:group_id])
    @title = "Grading #{@group.name}'s #{@assignment.name}"
    @assignment_type = @assignment.assignment_type
    @assignment_score_levels = @assignment.assignment_score_levels
    @grades = @group.students.map do |student|
      @assignment.grades.where(:student_id => student).first || @assignment.grades.new(:student => student, :assignment => @assignment, :graded_by_id => current_user, :status => "Graded")
    end
    @submit_message = "Submit Grades"
  end

  def group_update
    @assignment = current_course.assignments.find(params[:id])
    @group = @assignment.groups.find(params[:group_id])
    @grades = @group.students.map do |student|
      @assignment.grades.where(:student_id => student).first || @assignment.grades.new(:student => student, :assignment => @assignment, :graded_by_id => current_user, :status => "Graded", :group_id => @group.id)
    end
    grade_ids = []
    @grades = @grades.each do |grade|
      grade.update_attributes(params[:grade])
      grade_ids << grade.id
    end

    Resque.enqueue(GradeUpdater, grade_ids)

    respond_with @assignment
  end

  # Changing the status of a grade - allows instructors to review "Graded" grades, before they are "Released" to students
  def edit_status
    session[:return_to] = request.referer

    @assignment = current_course.assignments.find(params[:id])
    @title = "#{@assignment.name} Grade Statuses"
    @grades = @assignment.grades.find(params[:grade_ids])
  end

  def update_status
    @assignment = current_course.assignments.find(params[:id])
    @grades = @assignment.grades.find(params[:grade_ids])
    grade_ids = []
    @grades.each do |grade|
      grade.update_attributes!(params[:grade].reject { |k,v| v.blank? })
      grade_ids << grade.id
    end
    Resque.enqueue(GradeUpdater, grade_ids)

    if session[:return_to].present?
      redirect_to session[:return_to]
    else
      redirect_to @assignment
    end

    flash[:notice] = "Updated Grades!"
    
  end

  #upload grades for an assignment
  def import
    @assignment = current_course.assignments.find(params[:id])
    @title = "Import Grades for #{@assignment.name}"
  end

  #upload based on username
  def username_import
    @assignment = current_course.assignments.find(params[:id])
    @students = current_course.students
    grade_ids = []
    require 'csv'

    if params[:file].blank?
      flash[:notice] = "File missing"
      redirect_to assignment_path(@assignment)
    else
      CSV.foreach(params[:file].tempfile, :headers => true, :encoding => 'ISO-8859-1') do |row|
        @students.each do |student|
          if student.username.downcase == row[2].downcase && row[3].present?
            if student.grades.where(:assignment_id => @assignment).present?
              @assignment.all_grade_statuses_grade_for_student(student).tap do |grade|
                grade.raw_score = row[3].to_i
                grade.feedback = row[4]
                if grade.status == nil
                  grade.status = "Graded"
                end
                grade.instructor_modified = true
                grade.save!
                grade_ids << grade.id
              end
            else
              @assignment.grades.create! do |grade|
                grade.assignment_id = @assignment.id
                grade.student_id = student.id
                grade.raw_score = row[3].to_i
                grade.feedback = row[4]
                grade.status = "Graded"
                grade.instructor_modified = true
                grade.save!
                grade_ids << grade.id
              end
            end
          end
        end
      end
    Resque.enqueue(MultipleGradeUpdater, grade_ids)

    redirect_to assignment_path(@assignment), :notice => "Upload successful"
    end
  end

  #upload based on "email"
  def email_import
    @assignment = current_course.assignments.find(params[:id])
    @students = current_course.students
    grade_ids = []

    require 'csv'

    if params[:file].blank?
      flash[:notice] = "File missing"
      redirect_to assignment_path(@assignment)
    else
      CSV.foreach(params[:file].tempfile, :headers => true, :encoding => 'ISO-8859-1') do |row|
        @students.each do |student|
          if student.email.downcase == row[2].downcase && row[3].present?
            if student.grades.where(:assignment_id => @assignment).present?
              @assignment.all_grade_statuses_grade_for_student(student).tap do |grade|
                grade.raw_score = row[3].to_i
                grade.feedback = row[4]
                if grade.status == nil
                  grade.status = "Graded"
                end
                grade.instructor_modified = true
                grade.save!
                grade_ids << grade.id
              end
            else
              @assignment.grades.create! do |grade|
                grade.assignment_id = @assignment.id
                grade.student_id = student.id
                grade.raw_score = row[3].to_i
                grade.feedback = row[4]
                grade.status = "Graded"
                grade.instructor_modified = true
                grade.save!
                grade_ids << grade.id
              end
            end
          end
        end
      end
      Resque.enqueue(MultipleGradeUpdater, grade_ids)

      redirect_to assignment_path(@assignment), :notice => "Upload successful"
    end
  end

  private

  def new_grade_from_rubric_grades_attributes
    {
      course_id: current_course[:id],
      assignment_type_id: @assignment.assignment_type_id
    }
      .merge(current_assignment_and_student_ids)
      .merge(grade_attributes_from_rubric)
  end

  def current_assignment_and_student_ids
    {
      assignment_id: @assignment[:id],
      student_id: params[:student_id]
    }
  end

  def grade_attributes_from_rubric
    {
      raw_score: params[:points_given],
      submission_id: submission_id,
      point_total: params[:points_possible],
      status: params[:grade_status],
      instructor_modified: true
    }
  end

  def existing_metrics_as_json
    ActiveModel::ArraySerializer.new(rubric_metrics_with_tiers, each_serializer: ExistingMetricSerializer).to_json
  end

  def rubric_metrics_with_tiers
    @rubric_metrics_with_tiers ||= @rubric.metrics.order(:order).includes(:tiers)
  end

  def set_assignment
    @assignment = Assignment.find(params[:assignment_id]) if params[:assignment_id]
  end
end
