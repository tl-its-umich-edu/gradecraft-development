# spec/models/assignment_group_spec.rb

require 'spec_helper'

describe AssignmentGroup do

  it "is valid with assignment and group" do
    pending
    assignment_group = AssignmentGroup.new(
      assignment_id: "10", group_id: "1")
    expect(assignment_group).to be_valid
  end

  it "is invalid without assignment" do
    pending
    expect(AssignmentGroup.new(assignment_id: nil)).to have(1).errors_on(:assignment_id)
  end

  it "is invalid without group" do
    pending
    expect(AssignmentGroup.new(group_id: nil)).to have(1).errors_on(:group_id)
  end

end
