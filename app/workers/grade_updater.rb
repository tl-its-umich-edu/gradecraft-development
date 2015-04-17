class GradeUpdater
  @queue= :gradeupdater

  def self.perform(grade_id)
  	p "Starting GradeUpdater"
  	begin
	    grade = Grade.where(id: grade_id).includes(:assignment).load.first
	    grade.cache_student_and_team_scores
	    if grade.assignment.notify_released?
	      NotificationMailer.grade_released(grade.id).deliver
	    end
	rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
	end
  end
end
