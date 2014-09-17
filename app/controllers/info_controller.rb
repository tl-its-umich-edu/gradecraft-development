class InfoController < ApplicationController
  helper_method :sort_column, :sort_direction, :predictions

  before_filter :ensure_staff?, :except => [ :dashboard ]

  # Displays instructor dashboard, with or without Team Challenge dates 
  def dashboard
    @grade_scheme_elements = current_course.grade_scheme_elements
    if ! current_course.use_timeline?
      if current_user.is_student?
        redirect_to syllabus_path
      else
        redirect_to analytics_top_10_path
      end
    end
    if current_course.team_challenges?
      @events = current_course.assignments.timelineable.to_a + current_course.challenges
    else
      @events = current_course.assignments.timelineable.to_a
    end
  end

  # Displaying all ungraded (but submitted) assignments in the system, needs to have a new section that highlights "Graded-not-Released"
  def grading_status
    @team = current_course.teams.find_by(id: params[:team_id]) if params[:team_id]
    @students = current_course.students
    user_search_options = {}
    user_search_options['team_memberships.team_id'] = params[:team_id] if params[:team_id].present?
    @ungraded_submissions = current_course.submissions.ungraded
    @unreleased_grades = current_course.grades.not_released
    @in_progress_grades = current_course.grades.in_progress
    @count_unreleased = @unreleased_grades.not_released.count
    @count_ungraded = @ungraded_submissions.count
    @count_in_progress = @in_progress_grades.count
    @badges = current_course.badges.includes(:tasks)
  end

  #grade index export
  def gradebook
    @title = "#{current_course.name} Gradebook"
    respond_to do |format|
      format.html
      format.json { render json: current_course.assignments }
      format.csv { send_data current_course.gradebook_for_course(current_course) }
      format.xls { send_data current_course.gradebook_for_course(current_course).to_csv(col_sep: "\t") }
    end
  end

  #downloadable grades for course with  export
  def research_gradebook
    GradeExporter.perform_async(current_user.id, current_course.id)
    flash[:notice]="Your request to export grade data from course \"#{current_course.name}\" is currently being processed. We will email you the data shortly."
    redirect_to courses_path
  end

  # Chart displaying all of the student weighting choices thus far
  def choices
    @title = "View all #{current_course.weight_term} Choices"
    @assignment_types = current_course.assignment_types
    @team = current_course.teams.find_by(id: params[:team_id]) if params[:team_id]
  end

  # Display all grades in the course in list form
  def all_grades
    @grades = current_course.grades.paginate(:page => params[:page], :per_page => 500)
  end

  #Course wide leaderboard - excludes auditors from view
  def leaderboard
    @title = "#{current_course.name} Leaderboard"
    @team = current_course.teams.find_by(id: params[:team_id]) if params[:team_id]
    user_search_options = {}
    user_search_options['team_memberships.team_id'] = params[:team_id] if params[:team_id].present?
    @students = current_course.students.being_graded.order_by_high_score.includes(:earned_badges, :teams)
  end

end
