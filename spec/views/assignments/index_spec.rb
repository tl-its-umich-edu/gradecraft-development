# encoding: utf-8
require 'spec_helper'

describe "assignments/index" do

  before(:all) do
    @course = create(:course)
    @assignment_type_1 = create(:assignment_type, course: @course, max_value: 1000)
    @assignment_type_2 = create(:assignment_type, course: @course, max_value: 2000)
    @assignment_1 = create(:assignment, :assignment_type => @assignment_type_1)
    @assignment_2 = create(:assignment, :assignment_type => @assignment_type_2)
    @course.assignments <<[@assignment_1,@assignment_2]
  end

  before(:each) do
    assign(:title, "Assignments")
    assign(:assignment_types, [@assignment_type_1,@assignment_type_2])
    view.stub(:term_for).and_return("Assignment")
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Assignments", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select "ul.breadcrumbs" do
      assert_select "li", 2
    end
  end
end
