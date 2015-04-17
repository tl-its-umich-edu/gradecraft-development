module AssignmentsHelper
  def assignment_has_rubric?(assignment)
    "Yes" if assignment.has_rubric?
  end

  def tier_percent_of_total_graded(tier)
    (tier.rubric_grades.size/@graded_count).to_f rescue 0
  end
end
