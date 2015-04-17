require 'spec_helper'

describe CourseData do

  before do
    @course = build(:course)
    @course_data = CourseData.new(@course)
  end

  it "returns an alphabetical list of the students in the course" do
    student = create(:user, last_name: 'Zed')
    student.courses << @course
    student2 = create(:user, last_name: 'Alpha')
    student2.courses << @course
    @course_data.students.should eq([student2,student])
  end
end
