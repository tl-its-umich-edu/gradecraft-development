# encoding: utf-8
require 'spec_helper'

describe "assignments/show" do

  before(:all) do
    @course = create(:course)
    @assignment_type = create(:assignment_type, course: @course, max_value: 1000)
    @assignment = create(:assignment, :assignment_type => @assignment_type)
    @course.assignments << @assignment
    @student = create(:user)
    @student.courses << @course
  end

  before(:each) do
    assign(:title, "Assignments")
    assign(:assignment, @assignment)
    view.stub(:current_course).and_return(@course)
    view.stub(:current_student_data).and_return(StudentData.new(@student, @course))
  end

  describe "as student" do
    it "renders the assignment grades" do
      view.stub(:current_user).and_return(@student)
      render
    end
  end

  describe "as faculty" do
    it "renders the assignment management view" do
      view.stub(:current_user_is_staff?).and_return(true)
      view.stub(:term_for).and_return("Assignment")
      assign(:students, [@student])
      assign(:assignment_grades_by_student_id, {@student.id => nil})
      render
    end
  end
end
