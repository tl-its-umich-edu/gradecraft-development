class GradeExporter
  include Sidekiq::Worker

  def perform(user_id, course_id)
    user = User.find(user_id)
    course = Course.find(course_id)
    if course.present? && user.present?
      csv_data = course.research_grades_for_course(course)
      NotificationMailer.grade_export(course,user,csv_data).deliver
    end
  end
end
