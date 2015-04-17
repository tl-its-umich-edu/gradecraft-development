# encoding: utf-8
require 'spec_helper'

describe "assignments/edit" do

  before(:all) do
    @course = create(:course)
  #   # @assignment_type = create(:assignment_type, course: @course, max_value: 2000)
    @assignment = create(:assignment)
  #   @course.assignments <<[@assignment]
  #   @student = create(:user)
  #   @student.courses << @course
  end

  before(:each) do
    assign(:title, "Assignment")
    assign(:assignmet, @assignment)
    # assign(:students, [@student])
    # # assign(:assignment_types, [@assignment_type_1,@assignment_type_2])
    view.stub(:current_course).and_return(@course)
    view.stub(:term_for).and_return("Assignment")
    # view.stub(:current_course_data).and_return(CourseData.new(@course))
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Assignment", :count => 1
  end
end
