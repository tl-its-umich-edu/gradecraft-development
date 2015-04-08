# encoding: utf-8
require 'spec_helper'

describe "assignments/new" do

  before(:all) do
    @course = create(:course)
    #@assignment_type = create(:assignment_type, course: @course, max_value: 1000)
    @assignment = create(:assignment)
  end

  before(:each) do
    assign(:title, "New Assignment")
    assign(:assignment, @assignment)
    view.stub(:current_course).and_return(@course)
    view.stub(:term_for).and_return("Assignment")
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "New Assignment", :count => 1
  end
end
