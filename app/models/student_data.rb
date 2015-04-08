class StudentData < Struct.new(:student, :course)

  def membership
    @membership ||= CourseMembership.where(course_id: course.id, user_id: student.id)
  end

  def sums
    @sums ||= membership
  end

  #Released grades + Badges if they have value + Team score if it's present
  def score
    @score ||= membership.released_grade_score + membership.earned_badge_score + team_score
  end

  #Possible total points for student
  def point_total
    @point_total ||= membership.total_assignment_points_available + earned_badge_score
  end

  #Grabbing the associated course grade scheme info for a student
  def grade_level
    @grade_level ||= course.grade_level_for_score(score)
  end

  def element_level
    @element_level ||= course.element_for_score(score)
  end

  #Displays the student's current grade based on the student's score compared against the course grade scheme
  def grade_letter
    @grade_letter ||= course.grade_letter_for_score(score)
  end

  #Displays the predicted grade based on the student's predicted score compared against the course grade scheme
  def predicted_grade_letter
    @predicted_grade_letter ||= course.grade_letter_for_score(predicted_score)
  end

  #Summed score for a type of assignment type
  def score_for_assignment_type(assignment_type)
    assignment_type_scores[assignment_type.id]
  end

  def assignment_type_scores
    @assignment_type_scores ||= Hash.new { |h, k| h[k] = 0 }.tap do |assignment_type_scores|
      released_grades.assignment_type_scores.each do |assignment_type_id, score|
        assignment_type_scores[assignment_type_id] = score
      end
    end
  end

  #Summed total points for an assignment type
  def point_total_for_assignment_type(assignment_type)
    assignment_type_point_totals[assignment_type.id]
  end

  def assignment_type_point_totals
    @assignment_type_point_totals ||= Hash.new { |h, k| h[k] = 0 }.tap do |assignment_type_point_totals|
      course.assignments.assignment_type_point_totals_for_student(student).each do |assignment_type_id, point_total|
        assignment_type_point_totals[assignment_type_id] = point_total
      end
    end
  end

  #Total points for a single assignment
  def point_total_for_assignment(assignment)
    assignment_point_totals[assignment.id]
  end

  def assignment_point_totals
    @assignment_point_totals ||= {}.tap do |assignment_point_totals|
      course.assignments.point_totals_for_student(student).each do |assignment_id, point_total|
        assignment_point_totals[assignment_id] = point_total
      end
    end
  end

  #Points earned for a single assignment
  def score_for_assignment(assignment)
    assignment_scores[assignment.id] || 0
  end

  def assignment_scores
    @assignment_scores ||= Hash.new { |h, k| h[k] = 0 }.tap do |assignment_scores|
      released_grades.assignment_scores.each do |assignment_id, score|
        assignment_scores[assignment_id] = score
      end
    end
  end

  #Checking specifically if there is a released grade for an assignment
  def grade_released_for_assignment?(assignment)
    if grade_for_assignment(assignment).present?
      (grade_for_assignment(assignment).status == "Graded" && !assignment.release_necessary?) || grade_for_assignment(assignment).status == "Released"
    end
  end

  #Grabbing the grade for an assignment
  def grade_for_assignment(assignment)
    assignment_grades[assignment.id] || student.grades.new(assignment: assignment)
  end

  def assignment_grades
    @assignment_grades ||= {}.tap do |assignment_grades|
      student.grades.each do |grade|
        assignment_grades[grade.assignment_id] = grade
      end
    end
  end
  
  #Checking if the student's group has a submission for an assignment
  def group_submission_for_assignment?(assignment, group)
    assignment_submissions[assignment.id, group.id].present?
  end

  #Grabbing the student's group for a particular assignment
  def group_for_assignment(assignment)
    assignment_groups.where(assignment: assignment).first
  end

  #Checking specifically if there is a released grade for a challenge
  def grade_released_for_challenge?(challenge)
    (grade_for_challenge(challenge).is_graded? && !challenge.release_necessary?) || grade_for_challenge(challenge).is_released?
  end

  #Grabbing the grade for a challenge
  def grade_for_challenge(challenge)
    challenge_grades[challenge.id]
  end

  def challenge_grades(course)
    @challenge_grades ||= {}.tap do |challenge_grades|
      team_for_course(course).challenge_grades.each do |challenge_grade|
        challenge_grades[challenge_grade.challenge_id] = challenge_grade
      end
    end
  end

  #Grabbing a student's team for current course
  def team
    student.teams.where(course: course).first
  end

  #Grabbing the student's team's score
  def team_score
    (team.challenge_grade_score if team) || 0
  end
  
  ####MOVED TO user
  #Sum of all earned badges value for a student
  def earned_badge_score
    @earned_badge_score ||= membership.earned_badge_score # student.earned_badges.where(course: course).score
  end

  #All of a student's grades for a course
  def grades
    @grades ||= student.grades.where(course: course)
  end

  #All of a student's released grades for a course
  def released_grades
    @released_grades ||= student.grades.released
  end

  #Badges
  def earned_badge(badge)
    earned_badges[badge.id]
  end

  #Guessing one of these needs to come out? -ch
  def earned_badge?(badge)
    earned_badges[badge.id].present?
  end

  def earned_badges
    @earned_badges ||= {}.tap do |earned_badges|
      student.earned_badges.where(course: course).each do |earned_badge|
        earned_badges[earned_badge.badge_id] = earned_badge
      end
    end
  end

  def remaining_weights(course)
    course.total_assignment_weight - course.assignment_weight_for_student(student)
  end

  #Weights
  def weight_for_assignment_type(assignment_type)
    assignment_type_weights[assignment_type.id]
  end  

  #Groups for Assignments

  def group_submission_for_assignment?(assignment, group)
    assignment_submissions[assignment.id, group.id].present?
  end

  def group_for_assignment(assignment)
    assignment_groups.where(assignment: assignment).first
  end

  private

  def assignment_type_weights
    @assignment_type_weights ||= {}.tap do |assignment_type_weights|
      course.assignment_types.weights_for_student(student).each do |assignment_type_id, weight|
        assignment_type_weights[assignment_type_id] = weight
      end
    end
  end

  def assignment_submissions
    @assignment_submissions ||= {}.tap do |assignment_submissions|
      student.submissions.each do |submission|
        assignment_submissions[submission.assignment_id] = submission
      end
    end
  end

  def assignment_weights
    @assignment_weights ||= {}.tap do |assignment_weights|
      student.assignment_weights.each do |weights|
        assignment_weights[weights.assignment_id] = weights
      end
    end
  end

  def weight_for_assignment(assignment)
    assignment_weights[assignment.id]
  end
end
