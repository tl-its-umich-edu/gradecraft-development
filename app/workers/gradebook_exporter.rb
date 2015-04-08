class GradebookExporter
  @queue= :gradebookexporter

  def self.perform(user_id, course_id)
    p "Starting GradebookExporter"
    begin
      user = User.find(user_id)
      course = Course.find(course_id)
      if course.present? && user.present?
        csv_data = course.gradebook_for_course(course)
        NotificationMailer.gradebook_export(course,user,csv_data).deliver
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end
