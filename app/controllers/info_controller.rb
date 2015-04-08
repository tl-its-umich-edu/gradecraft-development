class InfoController < ApplicationController
  helper_method :sort_column, :sort_direction, :predictions

  before_filter :ensure_staff?, :except => [ :dashboard, :timeline_events ]

  # Displays instructor dashboard, with or without Team Challenge dates
  def dashboard
    @grade_scheme_elements = current_course.grade_scheme_elements
    #checking to see if the course uses the interactive timeline - if not sending students to their syllabus, and the staff to top 10
    if ! current_course.use_timeline?
      if current_user_is_student?
        redirect_to syllabus_path
      else
        redirect_to analytics_top_10_path
      end
    end
  end

  def timeline_events
    if current_course.team_challenges?
      @events = current_course.assignments.timelineable.with_due_date.to_a + current_course.challenges + current_course.events
    else
      @events = current_course.assignments.timelineable.with_due_date.to_a + current_course.events
    end
    render(:partial => 'info/timeline', :handlers => [:jbuilder], :formats => [:js])
  end



  def class_badges
    @title = "Awarded #{term_for :badges}"
  end

  # Displaying all ungraded, graded but unreleased, and in progress assignment submissions in the system
  def grading_status
    @title = "Grading Status"
    @team = current_course.teams.find_by(id: params[:team_id]) if params[:team_id]

    if @team
      @ungraded_submissions = current_course.submissions.ungraded
      @unreleased_grades = current_course.grades.not_released
      @in_progress_grades = current_course.grades.in_progress
      @count_unreleased = @unreleased_grades.not_released.count
      @count_ungraded = @ungraded_submissions.count
      @count_in_progress = @in_progress_grades.count
      @badges = current_course.badges.includes(:tasks)
    else
      @ungraded_submissions = current_course.submissions.ungraded
      @unreleased_grades = current_course.grades.not_released
      @in_progress_grades = current_course.grades.in_progress
      @count_unreleased = @unreleased_grades.not_released.count
      @count_ungraded = @ungraded_submissions.count
      @count_in_progress = @in_progress_grades.count
      @badges = current_course.badges.includes(:tasks)
    end

  end

  # Displaying all resubmisisons
  def resubmissions
    @title = "Resubmitted Assignments"
    @resubmissions = current_course.submissions.resubmitted
    @resubmission_count = @resubmissions.count
    @team = current_course.teams.find_by(id: params[:team_id]) if params[:team_id]
  end

  #grade index export
  def gradebook
    session[:return_to] = request.referer
    Resque.enqueue(GradebookExporter, current_user.id, current_course.id)  
    #GradebookExporter.perform_async(current_user.id, current_course.id)
    flash[:notice]="Your request to export the gradebook for \"#{current_course.name}\" is currently being processed. We will email you the data shortly."
    redirect_to session[:return_to]
  end

  def final_grades
    respond_to do |format|
      format.csv { send_data current_course.final_grades_for_course(current_course) }
      format.xls { send_data current_course.final_grades_for_course(current_course).to_csv(col_sep: "\t") }
    end
  end

  #downloadable grades for course with  export
  def research_gradebook
    Resque.enqueue(GradeExporter, current_user.id, current_course.id)  
    #GradeExporter.perform_async(current_user.id, current_course.id)
    flash[:notice]="Your request to export grade data from course \"#{current_course.name}\" is currently being processed. We will email you the data shortly."
    redirect_to courses_path
  end

  # Chart displaying all of the student weighting choices thus far
  def choices
    @title = "#{current_course.weight_term} Choices"
    @assignment_types = current_course.assignment_types
    @team = current_course.teams.find_by(id: params[:team_id]) if params[:team_id]
    user_search_options = {}
    user_search_options['team_memberships.team_id'] = params[:team_id] if params[:team_id].present?

    if @team
      students = current_course.students_being_graded_by_team(@team)
    else
      students = current_course.students_being_graded
    end

    @students = students
    @auditing = current_course.students_auditing
  end

  # Display all grades in the course in list form
  def all_grades
    @grades = current_course.grades.paginate(:page => params[:page], :per_page => 500)
  end
end
