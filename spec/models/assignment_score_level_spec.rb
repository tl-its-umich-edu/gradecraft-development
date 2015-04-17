# spec/models/assignment_score_level_spec.rb
require 'spec_helper'

describe AssignmentScoreLevel do

  #simple validations
  it "is valid with a name, a value, and an assignment" do
    assignment_score_level = AssignmentScoreLevel.new(
      name: "Level 1", value: "1000", assignment_id: "1")
    expect(assignment_score_level).to be_valid
  end
  it "is invalid without a name" do
    expect(AssignmentScoreLevel.new(name: nil)).to have(1).errors_on(:name)
  end
  it "is invalid without an assignment" do
    pending "make this true in the model"
    expect(AssignmentScoreLevel.new(assignment_id: nil)).to have(1).errors_on(:assignment_id)
  end
  it "is invalid without a value" do
    expect(AssignmentScoreLevel.new(value: nil)).to have(1).errors_on(:value)
  end

end
