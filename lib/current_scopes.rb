module CurrentScopes

  def self.included(base)
    base.helper_method :current_user, :current_course, :current_student, :current_student_data, :current_course_data
  end

  def current_course
    return unless current_user
    @__current_course ||= current_user.courses.find_by(id: session[:course_id]) if session[:course_id]
    @__current_course ||= current_user.default_course
  end

  def current_user_is_staff?
    return unless current_user && current_course
    current_user.is_staff?(current_course)
  end

  def current_user_is_admin?
    return unless current_user && current_course
    current_user.is_admin?(current_course)
  end

  def current_user_is_gsi?
    return unless current_user && current_course
    current_user.is_gsi?(current_course)
  end

  def current_user_is_student?
    return unless current_user && current_course
    current_user.is_student?(current_course)
  end

  def current_user_is_professor?
    return unless current_user && current_course
    current_user.is_professor?(current_course)
  end

  def current_student
    if current_user_is_staff?
      @__current_student ||= (current_course.students.find_by(id: params[:student_id]) if params[:student_id])
    else
      current_user
    end
  end

  def current_role
    return unless current_user && current_course
    @__current_role ||= current_user.course_memberships.where(course: current_course).first.role
  end

  def current_student_data
    @__current_student_data ||= StudentData.new(current_student, current_course)
  end

  def current_course_data
    @__current_course_data ||= CourseData.new(current_course)
  end

  def current_student=(student)
    @__current_student = student
  end

end
