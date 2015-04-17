class GradeExporter
  @queue= :gradeexporter

  def self.perform(user_id, course_id)
  	p "Starting GradeExporter"
    begin
      user = User.find(user_id)
      course = Course.find(course_id)
      if course.present? && user.present?
        csv_data = course.research_grades_for_course(course)
        NotificationMailer.grade_export(course,user,csv_data).deliver
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end
