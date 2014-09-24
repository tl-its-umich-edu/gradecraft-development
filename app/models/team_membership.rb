class TeamMembership < ActiveRecord::Base
  attr_accessible :team, :team_id, :student, :student_id

  belongs_to :team
  belongs_to :student, class_name: 'User'

  def team_score
    Grade
      .where(course_id: course.id)
      .where(student_id: user.id)
      .sum(&:final_score)
  end

  # (SELECT COALESCE(sum(challenge_grades.score), (0)::bigint) AS "coalesce" FROM (((challenge_grades JOIN challenges ON ((challenge_grades.challenge_id = challenges.id))) JOIN teams ON ((challenge_grades.team_id = teams.id))) JOIN team_memberships ON ((team_memberships.team_id = teams.id))) WHERE ((teams.course_id = m.course_id) AND (team_memberships.student_id = m.user_id))) AS challenge_grade_score,

  def challenge_grade_score
    ChallengeGrade
      .where(team_id: team_id)
  end
end
