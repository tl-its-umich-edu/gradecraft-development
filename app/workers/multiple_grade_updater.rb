class MultipleGradeUpdater
  @queue= :multiplegradeupdater

  def self.perform(grade_ids)
    p "Starting MultipleGradeUpdater"
    begin
      grades = Grade.where(id: grade_ids).includes(:assignment).load
      grades.each do |grade|
        grade.cache_student_and_team_scores
          # if grade.assignment.notify_released?
          #   NotificationMailer.grade_released(grade.id).deliver
          # end
        end
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end