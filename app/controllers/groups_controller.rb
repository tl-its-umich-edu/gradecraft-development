class GroupsController < ApplicationController
  before_filter :ensure_staff?, only: [:index, :review]

  def index
    @pending_groups = current_course.groups.pending
    @approved_groups = current_course.groups.approved
    @rejected_groups = current_course.groups.rejected
    @assignments = current_course.assignments.group_assignments
    @title = current_course.group_term.pluralize
  end

  def show
    if current_user_is_student?
      @user = current_user
    end
    @group = current_course.groups.find(params[:id])
    @title = "#{@group.name}"
    @assignments = current_course.assignments.group_assignments
  end

  def new
    @group = current_course.groups.new
    if current_user_is_student?
      @other_students = current_course.students.where.not(id: current_user.id)
    end
    @assignments = current_course.assignments.group_assignments.chronological.alphabetical
    @title = "Start a #{term_for :group}"
  end

  def review
    @group = current_course.groups.find(params[:id])
    @title = "Reviewing #{@group.name}"
  end

  def create
    @group = current_course.groups.new(params[:group])
    @assignments = current_course.assignments.group_assignments
    @group.students << current_user if current_user_is_student?
    if current_user_is_student?
      @group.approved = "Pending"
    else
      @group.approved = "Approved"
    end
    respond_to do |format|
      if @group.save
        #NotificationMailer.group_created(@group.id).deliver
        #NotificationMailer.group_notify(@group.id).deliver
        format.html { respond_with @group }
      else
        @title = "Start a #{term_for :group}"
        if current_user_is_student?
          @other_students = current_course.students.where.not(id: current_user.id)
        end
        format.html {render :action => "new", :group => @group }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @group = current_course.groups.find(params[:id])
    @assignments = current_course.assignments.group_assignments
    @title = "Editing #{@group.name} Details"
  end

  def update
    @group = current_course.groups.includes(:proposals).find(params[:id])
    @title = "Editing #{@group.name} Details"
    @assignments = current_course.assignments.group_assignments

    respond_to do |format|
      if @group.update_attributes(params[:group])
        #NotificationMailer.group_status_updated(@group.id).deliver
        format.html { respond_with @group }
      else
        if current_user_is_student?
          @other_students = current_course.students.where.not(id: current_user.id)
        end
        format.html {render :action => "edit", :group => @group }
      end
    end
  end

  def destroy
    @group = current_course.groups.find(params[:id])
    @group.destroy
    respond_with @group
  end
end
