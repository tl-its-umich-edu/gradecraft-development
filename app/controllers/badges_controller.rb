class BadgesController < ApplicationController

  before_filter :ensure_staff?, :except => [:index]

  def index
    if current_user_is_student?
      redirect_to my_badges_path
    end
    @title = "#{term_for :badges}"
  end

  def show
    @badge = current_course.badges.find(params[:id])
    @title = @badge.name
    @earned_badges = @badge.earned_badges
    @team = current_course.teams.find_by(id: params[:team_id]) if params[:team_id]
    if @team
      students = current_course.students_being_graded_by_team(@team)
    else
      students = current_course.students_being_graded
    end
    user_search_options = {}
    user_search_options['team_memberships.team_id'] = params[:team_id] if params[:team_id].present?
    @students = students
  end

  def new
    @title = "Create a New #{term_for :badge}"
    @badge = current_course.badges.new
  end

  def edit
    @badge = current_course.badges.find(params[:id])
    @title = "Editing #{@badge.name}"
  end

  def create

    if params[:badge][:badge_files_attributes].present?
      @badge_files = params[:badge][:badge_files_attributes]["0"]["file"]
      params[:badge].delete :badge_files_attributes
    end

    @badge = current_course.badges.new(params[:badge])

    if @badge_files
      @badge_files.each do |af|
        @badge.badge_files.new(file: af, filename: af.original_filename[0..49])
      end
    end

    respond_to do |format|
      if @badge.save
        format.html { redirect_to @badge, notice: "#{@badge.name} #{term_for :badge} successfully created" }
        format.json { render json: @badge, status: :created, location: @badge }
      else
        # TODO: refactor, see submissions_controller
        @title = "Create a New #{term_for :badge}"
        format.html { render action: "new" }
        format.json { render json: @badge.errors, status: :unprocessable_entity }
      end
    end
  end

  def update

    if params[:badge][:badge_files_attributes].present?
      @badge_files = params[:badge][:badge_files_attributes]["0"]["file"]
      params[:badge].delete :badge_files_attributes
    end

    @badge = current_course.badges.find(params[:id])

    if @badge_files
      @badge_files.each do |af|
        @badge.badge_files.new(file: af, filename: af.original_filename[0..49])
      end
    end

    respond_to do |format|

      if @badge.update_attributes(params[:badge])
        format.html { redirect_to @badge, notice: "#{@badge.name} #{term_for :badge} successfully updated" }
        format.json { head :ok }
      else
        # TODO: refactor, see submissions_controller
        @title = "Edit #{term_for :badge}"
        format.html { render action: "edit" }
        format.json { render json: @badge.errors, status: :unprocessable_entity }
      end
    end
  end

  def sort
    params[:"badge"].each_with_index do |id, index|
      current_course.assignments.update(id, position: index + 1)
    end
    render nothing: true
  end

  def destroy
    @badge = current_course.badges.find(params[:id])
    @name = @badge.name
    @badge.destroy

    respond_to do |format|
      format.html { redirect_to badges_path, notice: "#{@name} #{term_for :badge} successfully deleted" }
      format.json { head :ok }
    end
  end

end
