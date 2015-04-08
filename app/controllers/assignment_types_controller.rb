class AssignmentTypesController < ApplicationController

  before_filter :ensure_staff?

  #Display list of assignment types
  def index
    @title = "#{term_for :assignment_types}"
  end

  #See assignment type with all of its included assignments
  def show
    @assignment_type = current_course.assignment_types.find(params[:id])
    @title = "#{@assignment_type.name}"
  end

  #Create a new assignment type
  def new
    @title = "Create a New #{term_for :assignment_type}"
    @assignment_type = current_course.assignment_types.new
  end

  #Edit assignment type
  def edit
    @assignment_type = current_course.assignment_types.find(params[:id])
    @title = "Editing #{@assignment_type.name}"
  end

  #Create a new assignment type
  def create
    @assignment_type = current_course.assignment_types.new(params[:assignment_type])
    @title = "Create a New #{term_for :assignment_type}"
    @assignment_type.save

    respond_to do |format|
      if @assignment_type.save
        format.html { redirect_to @assignment_type, notice: "#{(term_for :assignment_type).titleize} #{@assignment_type.name} successfully created" }
        format.json { render json: @assignment_type, status: :created, location: @assignment_type }
      else
        format.html { render action: "new" }
        format.json { render json: @assignment_type.errors }
      end
    end
  end

  #Update assignment type
  def update
    @assignment_type = current_course.assignment_types.find(params[:id])
    @title = "Editing #{@assignment_type.name}"
    @assignment_type.update_attributes(params[:assignment_type])

    respond_to do |format|
      if (@assignment_type.universal_point_value.present?) && (@assignment_type.universal_point_value < 1)
        flash[:error] = 'Point value must be a positive number'
        format.html { render action: "new" }
        format.json { render json: @assignment_type.errors }
      elsif (@assignment_type.max_value?) && (@assignment_type.max_value < 1)
        flash[:error] = 'Maximum points must be a positive number'
        format.html { render action: "new" }
        format.json { render json: @assignment_type.errors }
      else
        if @assignment_type.save
          format.html { redirect_to assignments_path, notice: "#{(term_for :assignment_type).titleize} #{@assignment_type.name} successfully updated" }
        else
          format.html { render action: "new" }
          format.json { render json: @assignment_type.errors }
        end
      end
    end
  end

  def sort
    params[:"assignment-type"].each_with_index do |id, index|
      current_course.assignment_types.update(id, position: index + 1)
    end
    render nothing: true
  end

  def export_scores
    @assignment_type = current_course.assignment_types.find(params[:id])
    respond_to do |format|
      format.csv { send_data @assignment_type.export_scores }
    end
  end

  #display all grades for all assignments in an assignment type
  def all_grades  
    @assignment_type = current_course.assignment_types.find(params[:id])
    @title = "#{@assignment_type.name} Grade Patterns"
    
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

  #delete the specified assignment type
  def destroy
    @assignment_type = current_course.assignment_types.find(params[:id])
    @name = "#{@assignment_type.name}"
    @assignment_type.destroy
    redirect_to assignment_types_path, :notice => "#{(term_for :assignment_type).titleize} #{@name} successfully deleted"
  end
end
