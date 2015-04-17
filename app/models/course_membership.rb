class CourseMembership < ActiveRecord::Base
  belongs_to :course
  belongs_to :user

  attr_accessible :shared_badges, :auditing, :character_profile, :course_id, :user_id, :role

  ROLES = %w(student professor gsi admin)

  ROLES.each do |role|
    scope role.pluralize, ->(course) { where role: role }
  end

  scope :auditing, -> { where( :auditing => true ) }
  scope :being_graded, -> { where( :auditing => false) }

  def assign_role_from_lti(auth_hash)
    return unless auth_hash['extra'] && auth_hash['extra']['raw_info'] && auth_hash['extra']['raw_info']['roles']

    auth_hash['extra']['raw_info'].tap do |extra|

      case extra['roles'].downcase
      when /instructor/
        self.update_attribute(:role, 'professor')
      when /teachingassistant/
        self.update_attribute(:role, 'gsi')
      else
        self.update_attribute(:role, 'student')
      end
    end
  end

  # sum of all grade scores
  # where the membership course is the same as the grade course
  # where student id on the grade is the same as the membership user_id

  def is_team_member?
    return !(team_id.nil?)
  end

  def user_course_team
    @user_course_team ||= Team
      .where(course_id: course)
      .where("id in (select distinct team_id from team_memberships where student_id = ?)", user.id)
      .take
  end

  def course_assignments_point_total
    Assignment
      .where(course_id: course.id)
      .sum(:point_total)
  end

  # working, needs speed improvements
  def released_grade_score
    Grade
      .released
      .where(course_id: course.id)
      .where(student_id: user.id)
      .sum(:score)
  end

  #    (SELECT COALESCE(sum(earned_badges.score), (0)::bigint) AS "coalesce" FROM earned_badges WHERE ((earned_badges.course_id = m.course_id) AND (earned_badges.student_id = m.user_id))) AS earned_badge_score,
  def earned_badge_score # sum of all badges that you've earned that have points
    EarnedBadge
      .where(student_id: user.id)
      .where(course_id: course.id)
      .sum(:score)
  end

  def assignment_weight_count
    AssignmentWeight
      .where(student_id: user.id)
      .count
  end

  #    (SELECT COALESCE(sum(challenge_grades.score), (0)::bigint) AS "coalesce" FROM (((challenge_grades JOIN challenges ON ((challenge_grades.challenge_id = challenges.id))) JOIN teams ON ((challenge_grades.team_id = teams.id))) JOIN team_memberships ON ((team_memberships.team_id = teams.id))) WHERE ((teams.course_id = m.course_id) AND (team_memberships.student_id = m.user_id))) AS challenge_grade_score,
  #

  # sum of all challenge grades (same as assignments to grades) that belong to the team that you belong to
  def challenge_grade_score
    if user_course_team
      ChallengeGrade
        .where(team_id: user_course_team.id)
        .sum(:score)
    else
      0
    end

  end

  #    (SELECT COALESCE(sum(assignments.point_total), (0)::bigint) AS "coalesce" FROM assignments
  #    WHERE (((assignments.course_id = m.course_id)
  #    AND (m.user_id = m.user_id)) AND (EXISTS (SELECT 1 FROM released_grades
  #    WHERE ((released_grades.assignment_id = assignments.id)
  #    AND (released_grades.student_id = m.user_id))))))
  #    AS in_progress_assignment_score,

  # total possible score for all completed assignments for the student/user
  def in_progress_assignment_score
    Assignment
      .where("id in (select distinct id from submissions where student_id = ? and course_id = ?)", user.id, course.id)
      .released(user) # scope in Assignment
      .sum(:point_total)
  end

  #    SELECT m.id, m.id AS course_membership_id, m.course_id, m.user_id, md5(pg_catalog.concat(m.course_id, m.user_id, (SELECT COALESCE(sum(date_part('epoch'::text, earned_badges.updated_at)), (0)::double precision) AS "coalesce" FROM earned_badges WHERE ((earned_badges.course_id = m.course_id) AND (earned_badges.student_id = m.user_id))))) AS earned_badges_key, md5(pg_catalog.concat(m.course_id, m.user_id, (SELECT COALESCE(sum(date_part('epoch'::text, submissions.updated_at)), (0)::double precision) AS "coalesce"
  #
  #    FROM submissions
  #    WHERE ((submissions.course_id = m.course_id) AND (submissions.student_id = m.user_id))))) AS submissions_key, md5(pg_catalog.concat(m.course_id, m.user_id, (SELECT COALESCE(sum(date_part('epoch'::text, aw.updated_at)), (0)::double precision) AS "coalesce" FROM assignment_weights aw WHERE ((aw.student_id = m.user_id) AND (aw.course_id = aw.course_id))))) AS assignment_weights_key,
  #    (SELECT COALESCE(sum(a.point_total), (0)::bigint) AS "coalesce" FROM assignments a WHERE (a.course_id = m.course_id)) AS assignment_score,
  #    earned badges
  #    submissions
  #
  # combination of grades for completed assignments, including assignment weights where they exist
  #
  # actual score on all completed assignments
  # formerly 'assigment_score'
  def earned_point_total
    Submission.includes(:grade, :rubric_grades, assignment: [:assignment_weights])
      .where(course_id: course.id)
      .where(student_id: user.id)
      .inject(0) do |memo, submission|
        assignment_weight = student_assignment_weights.select do |assignment_weight|
          assignment_weight.student_id == user.id and assignment_weight.assignment_id == submission.assignment[:id]
        end.first

        if assignment_weight
          memo << assignment_weight.point_total
        else
          submission.assignment.point_total
        end
      end
  end

  def assignment_score
    EarnedBadge
      .where(student_id: user.id)
      .where(course_id: course.id)
      .sum(:score)
  end

  def student_assignment_weights
    @student_assignment_weights ||= AssignmentWeight.where(student_id: user.id, course_id: course.id)
  end

  def test_assignment_score
    Submission.includes(:grade, :rubric_grades, assignment: [:assignment_weights])
      .where(course_id: 1)
      .where(student_id: 52)
      .inject(0) do |memo, submission|
        assignment_weight = student_assignment_weights.select do |assignment_weight|
          assignment_weight.student_id == 52 and assignment_weight.assignment_id == submission.assignment[:id]
        end.first

        if assignment_weight
          memo << assignment_weight.point_total
        else
          submission.assignment.point_total
        end
      end
  end

  def sql_assignment_score
    ActiveRecord::Base.connection.execute()
  end

  # (SELECT COALESCE(sum(grades.score), (0)::bigint) AS "coalesce" FROM grades WHERE ((grades.course_id = m.course_id) AND (grades.student_id = m.user_id))) AS grade_score,
  def grade_score
    Grade
      .where(course_id: course.id)
      .where(student_id: user.id)
      .sum(:final_score)
  end

  def team_score
    Grade
      .where(course_id: course.id)
      .where(student_id: user.id)
      .sum(:final_score)
  end

  #    (SELECT sum(COALESCE(assignment_weights.point_total, assignments.point_total))
  #    AS sum FROM (assignments
  #    WHERE (assignments.course_id = m.course_id))
  #    AS weighted_assignment_score,
  #
  # Total possible points for all assignments
  # formerly weighted_assignment_score
  def total_assignment_points_available
    Assignment
      .joins("LEFT JOIN assignment_weights ON assignments.id = assignment_weights.assignment_id")
      .where("assignments.id in (select distinct assignment_id from assignment_weights where student_id = ?)", user.id)
      .where(course_id: course.id)
      .sum(:point_total)
  end

#    (SELECT count(*) AS count FROM assignment_weights WHERE (assignment_weights.student_id = m.user_id)) AS assignment_weight_count, cck.course_key, cck.assignments_key, cck.grades_key, cck.badges_key FROM (course_memberships m JOIN course_cache_keys cck ON ((m.course_id = cck.id)));

  protected
  def student_id
    @student_id ||= user.id
  end
end
