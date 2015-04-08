class ScoreRecalculator
  @queue= :scorerecalculator

  def self.perform(student_id, course_id)
  	p "Starting ScoreRecalculator"
  	begin
    	student = User.find(student_id)
    	student.cache_course_score(course_id)
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
	end
  end
end
