#grade_spec.rb

require 'spec_helper'

describe Grade do

  before do
    @grade = build(:grade)
  end

  subject { @grade }

  it { should respond_to("raw_score")}
  it { should respond_to("assignment_id")}
  it { should respond_to("feedback")}
  it { should respond_to("created_at")}
  it { should respond_to("updated_at")}
  it { should respond_to("complete")}
  it { should respond_to("semis")}
  it { should respond_to("finals")}
  it { should respond_to("type")}
  it { should respond_to("status")}
  it { should respond_to("attempted")}
  it { should respond_to("substantial")}
  it { should respond_to("final_score")}
  it { should respond_to("submission_id")}
  it { should respond_to("course_id")}
  it { should respond_to("shared")}
  it { should respond_to("student_id")}
  it { should respond_to("task_id")}
  it { should respond_to("group_id")}
  it { should respond_to("group_type")}
  it { should respond_to("score")}
  it { should respond_to("assignment_type_id")}
  it { should respond_to("point_total")}
  it { should respond_to("admin_notes")}
  it { should respond_to("graded_by_id")}
  it { should respond_to("team_id")}
  it { should respond_to("predicted_score")}
  it { should respond_to("instructor_modified")}


  it { should be_valid }

  it "is valid with an assignment, student, assignment_type, and course" do
    expect(build(:grade)).to be_valid
  end

  it "is invalid without an assignment" do
    # delegations to assignment cause errors on save,
    # maybe there is a better way to test this?
    @grade.assignment = nil
    expect{@grade.save!}.to raise_error
  end

  it "is invalid without a student" do
    @grade.student = nil
    expect(@grade).to have(1).errors_on(:student)
  end

  it "is invalid without a course" do
    @grade.course = nil
    expect(@grade).to have(1).errors_on(:course)
  end

  it "is invalid without an assignment type" do
    @grade.assignment.assignment_type = nil
    expect(@grade).to have(1).errors_on(:assignment_type)
  end

  it "does not allow duplicate grades per student" do
    @grade.save!
    expect(build(:grade, course: @grade.course, assignment: @grade.assignment, student: @grade.student)).to_not be_valid
  end
end
