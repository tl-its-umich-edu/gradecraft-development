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
    new_course.save
    redirect_to courses_path
  end

  def create
    @course = Course.new(params[:course])

    if @course.max_group_size.present? && @course.min_group_size.present? && @course.max_group_size < @course.min_group_size
      flash[:error] = 'Maximum group size must be greater than minimum group size.'
      render :action => "new", :course => @course
    else
      respond_to do |format|
        if @course.save
          @course.course_memberships.create(:user_id => current_user.id)
          session[:course_id] = @course.id
          format.html { redirect_to course_path(@course), notice: "Course #{@course.name} successfully created" }
          format.json { render json: @course, status: :created, location: @course }
        else
          format.html { render action: "new" }
          format.json { render json: @course.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def update
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.update_attributes(params[:course])
        if @course.max_group_size.present? && @course.min_group_size.present? && @course.max_group_size < @course.min_group_size
          flash[:error] = 'Maximum group size must be greater than minimum group size.'
          format.html { render action: "edit" }
          format.json { render json: @course.errors, status: :unprocessable_entity }
        else
          format.html { redirect_to @course, notice: "Course #{@course.name} successfully updated" }
          format.json { head :no_content }
        end
      else
        format.html { render action: "edit" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
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
end
