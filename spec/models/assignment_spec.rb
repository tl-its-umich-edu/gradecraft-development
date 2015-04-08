# spec/models/assignment_spec.rb
require 'spec_helper'

describe Assignment do

  before do
    @assignment = build(:assignment)
  end

  subject { @assignment }

  it { should respond_to("name")}
  it { should respond_to("description")}
  it { should respond_to("point_total")}
  it { should respond_to("due_at")}
  it { should respond_to("created_at")}
  it { should respond_to("updated_at")}
  it { should respond_to("level")}
  it { should respond_to("present")}
  it { should respond_to("course_id")}
  it { should respond_to("assignment_type_id")}
  it { should respond_to("grade_scheme_id")}
  it { should respond_to("grade_scope")}
  it { should respond_to("close_time")} #TODO delete and confirm, now "due_at"
  it { should respond_to("open_time")} #TODO delete and confirm, now "open_at"
  it { should respond_to("required")}
  it { should respond_to("accepts_submissions")}
  it { should respond_to("student_logged")}
  it { should respond_to("release_necessary")}
  it { should respond_to("open_at")}
  it { should respond_to("icon")}
  it { should respond_to("can_earn_multiple_times")}
  it { should respond_to("visible")}
  it { should respond_to("category_id")}
  it { should respond_to("resubmissions_allowed")}
  it { should respond_to("max_submissions")}
  it { should respond_to("accepts_submissions_until")}
  it { should respond_to("accepts_resubmissions_until")}
  it { should respond_to("grading_due_at")}
  it { should respond_to("role_necessary_for_release")}
  it { should respond_to("media")}
  it { should respond_to("thumbnail")}
  it { should respond_to("media_credit")}
  it { should respond_to("media_caption")}
  it { should respond_to("points_predictor_display")}
  it { should respond_to("notify_released")}
  it { should respond_to("mass_grade_type")}
  it { should respond_to("include_in_timeline")}
  it { should respond_to("include_in_predictor")}
  it { should respond_to("position")}
  it { should respond_to("include_in_to_do")}
  it { should respond_to("student_logged_button_text")}
  it { should respond_to("student_logged_revert_button_text")}
  it { should respond_to("use_rubric")}
  it { should respond_to("accepts_attachments")}
  it { should respond_to("accepts_text")}
  it { should respond_to("accepts_links")}

  it { should be_valid }

  #validations
  it "is valid with a name and assignment type" do
    expect(build(:assignment)).to be_valid
  end

  it "is invalid without a name" do
    expect(build(:assignment, name: nil)).to have(1).errors_on(:name)
  end

  it "is invalid without an assignment type" do
    expect(build(:assignment, assignment_type: nil)).to have(1).errors_on(:assignment_type_id)
  end

  it "has optional dates associated with it" do
    pending
    #TODO open_at, due_at, accepted_until business logic
    #TODO remove open_time, close_time
  end

  describe "gradebook for assignment" do
    it "returns sample csv data, including ungraded students" do
      course = create(:course)
      course.assignments << @assignment
      student = create(:user)
      student.courses << course
      submission = create(:submission, student: student, assignment: @assignment)
      @assignment.gradebook_for_assignment.should eq("First Name,Last Name,Uniqname,Score,Raw Score,Statement,Feedback,Last Updated\n#{student.first_name},#{student.last_name},#{student.username},\"\",\"\",\"#{submission.text_comment}\",\"\"\n")
    end

    it "also returns grade fields with instructor modified grade" do
      course = create(:course)
      course.assignments << @assignment
      student = create(:user)
      student.courses << course
      grade = create(:grade, assignment: @assignment, student: student, feedback: "good jorb!", instructor_modified: true)
      submission = create(:submission, grade: grade, student: student, assignment: @assignment)
      @assignment.gradebook_for_assignment.should eq("First Name,Last Name,Uniqname,Score,Raw Score,Statement,Feedback,Last Updated\n#{student.first_name},#{student.last_name},#{student.username},0,0,\"#{submission.text_comment}\",good jorb!,\"#{grade.updated_at}\"\n")
    end
  end

  describe "email based grade import" do
    it "returns sample csv data, including ungraded students" do
      course = create(:course)
      course.assignments << @assignment
      student = create(:user)
      student.courses << course
      @assignment.email_based_grade_import.should eq("First Name,Last Name,Email,Score,Feedback\n#{student.first_name},#{student.last_name},#{student.email},\"\",\"\"\n")
    end

    it "also returns grade fields with instructor modified grade" do
      course = create(:course)
      course.assignments << @assignment
      student = create(:user)
      student.courses << course
      grade = create(:grade, assignment: @assignment, student: student, feedback: "good jorb!", instructor_modified: true)
      submission = create(:submission, grade: grade, student: student, assignment: @assignment)
      @assignment.email_based_grade_import.should eq("First Name,Last Name,Email,Score,Feedback\n#{student.first_name},#{student.last_name},#{student.email},#{grade.score},#{grade.feedback}\n")
    end
  end

  describe "username based grade import" do
    it "returns sample csv data, including ungraded students" do
      course = create(:course)
      course.assignments << @assignment
      student = create(:user)
      student.courses << course
      @assignment.username_based_grade_import.should eq("First Name,Last Name,Username,Score,Feedback\n#{student.first_name},#{student.last_name},#{student.username},\"\",\"\"\n")
    end

    it "returns grade fields with instructor modified grade" do
      course = create(:course)
      course.assignments << @assignment
      student = create(:user)
      student.courses << course
      grade = create(:grade, assignment: @assignment, student: student, feedback: "good jorb!", instructor_modified: true)
      submission = create(:submission, grade: grade, student: student, assignment: @assignment)
      @assignment.username_based_grade_import.should eq("First Name,Last Name,Username,Score,Feedback\n#{student.first_name},#{student.last_name},#{student.username},#{grade.score},#{grade.feedback}\n")
    end

    it "returns students in csv alphabetized by last name" do
      course = create(:course)
      course.assignments << @assignment
      student = create(:user, last_name: 'Zed')
      student.courses << course
      student2 = create(:user, last_name: 'Alpha')
      student2.courses << course
      @assignment.username_based_grade_import.should match(/Alpha.*\n.*Zed/)
    end

    it "handles a subset of students when passed in the params" do
      course = create(:course)
      course.assignments << @assignment
      student = create(:user)
      student.courses << course
      student2 = create(:user)
      student2.courses << course
      @assignment.username_based_grade_import({students: [student]}).should_not match(student2.last_name)
    end
  end
end
