class GradesController < ApplicationController
  respond_to :html, :json

  before_filter :ensure_staff?, :except => [:self_log, :show, :predict_score]

  def index
    @assignment = current_course.assignments.find(params[:assignment_id])
    redirect_to assignment_path(@assignment)
  end

  def show
    @assignment = current_course.assignments.find(params[:assignment_id])
    @grade = @assignment.grades.find(params[:id])
    if @assignment.has_groups? && current_user.is_staff?
      @group = @assignment.groups.find(params[:group_id])
    elsif @assignment.has_groups? && current_user.is_student?

    end
  end

  def gradebook
    @assignments = current_course.assignments.sort_by &:id
    @students = current_course.users.students.includes(:grades)
  end

  def new
    @assignment = current_course.assignments.find(params[:assignment_id])
    @assignment_type = @assignment.assignment_type
    @score_levels = @assignment_type.score_levels
    @student = current_course.students.find(params[:student_id])
    @title = "Grading #{@student.name}'s #{@assignment.name}"
    @grade = @student.grades.new(assignment: @assignment)
    @submit_message = "Submit Grade"
  end

  def edit
    @assignment = current_course.assignments.find(params[:assignment_id])
    @grade = @assignment.grades.find(params[:id])
    @assignment_type = @assignment.assignment_type
    @score_levels = @assignment_type.score_levels
    @student = current_course.students.find(params[:student_id])
    @submit_message = "Update Grade"
    @title = "Editing #{@student.name}'s Grade for #{@assignment.name}"
  end

  def create
    @assignment = current_course.assignments.find(params[:assignment_id])
    @grade = @assignment.grades.build(params[:grade])
    @grade.graded_by = current_user
    if !@assignment.release_necessary?
      @grade.status = "Graded"
    end
    @grade.save
    respond_to do |format|
      if @grade.save
        if @assignment.notify_released? && @grade.is_released?
          NotificationMailer.grade_released(@grade.id).deliver
        end
        format.html { redirect_to @assignment, notice: 'Grade was successfully created.' }
        format.json { render json: @grade, status: :created, location: @grade }
      else
        format.html { render action: "new", notice: 'Oh no! We cannot submit this grade.' }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @assignment = current_course.assignments.find(params[:assignment_id])
    @grade = @assignment.grades.find(params[:id])
    if !@assignment.release_necessary?
      @grade.status = "Graded"
    end
    respond_to do |format|
      if @grade.update_attributes(params[:grade])
        if @assignment.notify_released? && @grade.status == "Released"
          NotificationMailer.grade_released(@grade.id).deliver
        end
        format.html { redirect_to @assignment, notice: 'Grade was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @assignment = current_course.assignments.find(params[:assignment_id])
    @grade = @assignment.grades.find(params[:id])
    @grade.destroy

    redirect_to assignment_path(@assignment), notice: "#{ @grade.student.name}'s #{@assignment.name} grade was successfully deleted."
  end

  def self_log
    @assignment = current_course.assignments.find(params[:assignment_id])
    if @assignment.open?
      @grade = current_student_data.grade_for_assignment(@assignment)
      @grade.raw_score = params[:present] == 'true' ? @assignment.point_total : 0
      @grade.status = "Graded"
      respond_to do |format|
        if @grade.save
          format.html { redirect_to dashboard_path, notice: 'Thank you for logging your grade!' }
        else
          format.html { redirect_to dashboard_path, notice: "We're sorry, this grade could not be added." }
        end
      end
    else
      format.html { redirect_to dashboard_path, notice: "We're sorry, this assignment is no longer open." }
    end
  end

  def predict_score
    @assignment = current_course.assignments.find(params[:assignment_id])
    @grade = current_user.grades.where(status: nil).find_or_initialize_by(assignment: @assignment)
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

  def mass_edit
    @assignment = current_course.assignments.find(params[:id])
    @title = "Quick Grade #{@assignment.name}"
    @assignment_type = @assignment.assignment_type
    @score_levels = @assignment_type.score_levels
    @team = current_course.teams.find_by(id: params[:team_id]) if params[:team_id]
    user_search_options = {}
    user_search_options['team_memberships.team_id'] = params[:team_id] if params[:team_id].present?
    @students = current_course.students.includes(:teams).where(user_search_options).alpha
    @grades = @students.map do |s|
      @assignment.grades.where(:student_id => s).first || @assignment.grades.new(:student => s, :assignment => @assignment, :graded_by_id => current_user, :status => "Graded")
    end
  end

  def mass_update
    @assignment = current_course.assignments.find(params[:id])
    if @assignment.update_attributes(params[:assignment])
      respond_with @assignment
    else
      @title = "Quick Grade #{@assignment.name}"
      @assignment_type = @assignment.assignment_type
      @score_levels = @assignment_type.score_levels
      user_search_options = {}
      user_search_options['team_memberships.team_id'] = params[:team_id] if params[:team_id].present?
      @students = current_course.users.students.includes(:teams).where(user_search_options).alpha
      @grades = @students.map do |s|
        @assignment.grades.where(:student_id => s).first || @assignment.grades.new(:student => s, :assignment => @assignment, :graded_by_id => current_user, :status => 'Graded')
      end
      respond_with @assignment, :template => "grades/mass_edit"
    end
  end

  def group_edit
    @assignment = current_course.assignments.find(params[:assignment_id])
    @group = @assignment.groups.find(params[:group_id])
    @title = "Grading #{@group.name}'s #{@assignment.name}"
    @assignment_type = @assignment.assignment_type
    @score_levels = @assignment_type.score_levels
    @grades = @group.students.map do |student|
      @assignment.grades.where(:student_id => student).first || @assignment.grades.new(:student => student, :assignment => @assignment, :graded_by_id => current_user, :status => "Graded")
    end
    @submit_message = "Submit Grades"
  end

  def group_update
    @assignment = current_course.assignments.find(params[:id])
    if @assignment.update_attributes(params[:assignment])
      respond_with @assignment
    else
      @title = "Quick Grade #{@assignment.name}"
      @assignment_type = @assignment.assignment_type
      @score_levels = @assignment_type.score_levels
      @group = @assignment.groups.find(params[:group_id])
      @students = @group.students
      @grades = @students.map do |s|
        @assignment.grades.where(:student_id => s).first || @assignment.grades.new(:student => s, :assignment => @assignment, :graded_by_id => current_user, :status => 'Graded')
      end
      respond_with @assignment, :template => "grades/mass_edit"
    end
  end

  def edit_status
    @assignment = current_course.assignments.find(params[:assignment_id])
    @title = "#{@assignment.name} Grade Statuses"
    @grades = @assignment.grades.find(params[:grade_ids])
  end

  def update_status
    @assignment = current_course.assignments.find(params[:assignment_id])
    @grades = @assignment.grades.find(params[:grade_ids])
    @grades.each do |grade|
      grade.update_attributes!(params[:grade].reject { |k,v| v.blank? })
      if @assignment.notify_released? && grade.status == "Released"
        NotificationMailer.grade_released(grade.id).deliver
      end
    end
    flash[:notice] = "Updated grades!"
    redirect_to assignment_path(@assignment)
  end

end
