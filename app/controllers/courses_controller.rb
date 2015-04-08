class CoursesController < ApplicationController

  before_filter :ensure_staff?, :except => :timeline
  before_filter :ensure_admin?, :only => [:index]

  def index
    @title = "Course Index"
    @courses = Course.all

    respond_to do |format|
      format.html
      format.json { render json: @courses }
    end
  end

  def show
    @title = "Course Settings"
    @course = current_course
  end

  def new
    @title = "Create a New Course"
    @course = Course.new
  end

  def edit
    @title = "Editing Basic Settings"
    @course = Course.find(params[:id])
  end

  # Important for instructors to be able to copy one course's structure into a new one - does not copy students or grades
  def copy
    @course = Course.find(params[:id])
    new_course = @course.dup
    new_course.name.prepend("Copy of ")
    new_course.save
    if @course.badges.present?
      @course.badges.each do |b|
        nb = b.dup
        nb.course_id = new_course.id
        nb.save
      end
    end
    if @course.assignment_types.present?
      @course.assignment_types.each do |at|
        nat = at.dup
        nat.course_id = new_course.id
        nat.save
        at.assignments.each do |a|
          na = a.dup
          na.assignment_type_id = nat.id
          na.course_id = new_course.id
          na.save
          if a.assignment_score_levels.present?
            a.assignment_score_levels.each do |asl|
              nasl = asl.dup 
              nasl.assignment_id = na.id 
              nasl.save
            end
          end
        end
      end
    end
    if @course.challenges.present?
      @course.challenges.each do |c|
        nc = c.dup
        nc.course_id = new_course.id
        nc.save
      end
    end
    if @course.grade_scheme_elements.present?
      @course.grade_scheme_elements.each do |gse|
        ngse = gse.dup
        ngse.course_id = new_course.id
        ngse.save
      end
    end
    respond_to do |format|
      if new_course.save
        new_course.course_memberships.create(:user_id => current_user.id, :role => current_user.course_memberships.where(:course_id => current_course.id).first.role)
        session[:course_id] = new_course.id
        format.html { redirect_to course_path(@course), notice: "#{@course.name} successfully copied" }
      else
        format.html { render action: "new" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
    
  end

  def create
    @course = Course.new(params[:course])
    @title = "Create a New Course"

    respond_to do |format|
      if @course.save
        @course.course_memberships.create(:user_id => current_user.id, :role => current_user.course_memberships.where(:course_id => current_course.id).first.role)
        session[:course_id] = @course.id
        format.html { redirect_to course_path(@course), notice: "Course #{@course.name} successfully created" }
        format.json { render json: @course, status: :created, location: @course }
      else
        format.html { render action: "new" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @course = Course.find(params[:id])
    @title = "Editing Basic Settings"

    respond_to do |format|
      if @course.update_attributes(params[:course])
        format.html { redirect_to @course, notice: "Course #{@course.name} successfully updated" }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def timeline_settings
    @course = current_course
    @assignments = current_course.assignments
    @title = "Timeline Settings"
  end

  def timeline_settings_update
    @course = current_course
    if @course.update_attributes(params[:course])
      redirect_to dashboard_path
    else
      @assignments = @course.assignments
      @title = "Timeline Settings"
      render :action => "timeline_settings", :course => @course
    end
  end

  def predictor_settings
    @course = current_course
    @assignments = current_course.assignments
    @title = "Predictor Settings"
  end

  def predictor_settings_update
    @course = current_course
    if @course.update_attributes(params[:course])
      respond_with @course
    else
      @assignments = @course.assignments
      @title = "Predictor Settings"
      render :action => "predictor_settings", :course => @course
    end
  end

  def predictor_preview
    @assignments = current_course.assignments
    @grade_scheme_elements = current_course.grade_scheme_elements
    @grade_levels_json = @grade_scheme_elements.order(:low_range).pluck(:low_range, :letter, :level).to_json
  end

  def destroy
    @course = Course.find(params[:id])
    @name = @course.name
    @course.destroy

    respond_to do |format|
      format.html { redirect_to courses_url, notice: "Course #{@name} successfully deleted" }
      format.json { head :no_content }
    end
  end

  def assignments
    @course = current_course
    @assignments = EventSearch.new(:current_user => current_user, :events => @course.events).find
    respond_with @assignments do |format|
      format.ics do
        render :text => CalendarBuilder.new(:assignments => @assignments).to_ics, :content_type => 'text/calendar'
      end
    end
  end

  def timeline
    @course = current_course
    if current_course.team_challenges?
      @events = @course.assignments.timelineable + @course.challenges
    else
      @events = @course.assignments.timelineable
    end
  end

  def export_earned_badges
    @course = current_course
    respond_to do |format|
      format.csv { send_data @course.earned_badges_for_course }
    end
  end

end
