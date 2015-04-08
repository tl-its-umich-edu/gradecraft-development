# encoding: utf-8
require 'spec_helper'

describe "assignments/rubric_grades_review" do

  before(:all) do
    @course = create(:course)
    @assignment = create(:assignment)
  end

  before(:each) do
    assign(:title, "Assignment")
    assign(:assignmet, @assignment)
    view.stub(:current_course).and_return(@course)
    view.stub(:term_for).and_return("Assignment")
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Assignment Detailed Grades (#{ points @assignment.point_total } points)", :count => 1
  end
end
