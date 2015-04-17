require 'spec_helper'

describe Course do

  before do
    @course = build(:course)
  end

  subject { @course }

  it { should respond_to("name")}
  it { should respond_to("courseno")}
  it { should respond_to("year")}
  it { should respond_to("semester")}
  it { should respond_to("grade_scheme_id")}
  it { should respond_to("created_at")}
  it { should respond_to("updated_at")}
  it { should respond_to("badge_setting")}
  it { should respond_to("team_setting")}
  it { should respond_to("user_term")}
  it { should respond_to("team_term")}
  it { should respond_to("homepage_message")}
  it { should respond_to("status")}
  it { should respond_to("group_setting")}
  it { should respond_to("badge_set_id")}
  it { should respond_to("assignment_weight_close_at")}
  it { should respond_to("team_roles")}
  it { should respond_to("team_leader_term")}
  it { should respond_to("group_term")}
  it { should respond_to("assignment_weight_type")}
  it { should respond_to("accepts_submissions")}
  it { should respond_to("teams_visible")}
  it { should respond_to("badge_use_scope")}
  it { should respond_to("weight_term")}
  it { should respond_to("predictor_setting")}
  it { should respond_to("badges_value")}
  it { should respond_to("max_group_size")}
  it { should respond_to("min_group_size")}
  it { should respond_to("shared_badges")}
  it { should respond_to("graph_display")}
  it { should respond_to("default_assignment_weight")}
  it { should respond_to("tagline")}
  it { should respond_to("academic_history_visible")}
  it { should respond_to("office")}
  it { should respond_to("phone")}
  it { should respond_to("class_email")}
  it { should respond_to("twitter_handle")}
  it { should respond_to("twitter_hashtag")}
  it { should respond_to("location")}
  it { should respond_to("office_hours")}
  it { should respond_to("meeting_times")}
  it { should respond_to("media_file")}
  it { should respond_to("media_credit")}
  it { should respond_to("media_caption")}
  it { should respond_to("badge_term")}
  it { should respond_to("assignment_term")}
  it { should respond_to("challenge_term")}
  it { should respond_to("use_timeline")}
  it { should respond_to("grading_philosophy")}
  it { should respond_to("total_assignment_weight")}
  it { should respond_to("max_assignment_weight")}
  it { should respond_to("check_final_grade")}
  it { should respond_to("character_profiles")}
  it { should respond_to("lti_uid")}
  it { should respond_to("team_score_average")}
  it { should respond_to("team_challenges")}
  it { should respond_to("max_assignment_types_weighted")}
  it { should respond_to("point_total")}
  it { should respond_to("in_team_leaderboard")}
  it { should respond_to("add_team_score_to_student")}
  it { should respond_to("start_date")}
  it { should respond_to("end_date")}

  it { should be_valid }

  it "is valid with an assignment, student, assignment_type, and course" do
    expect(build(:course)).to be_valid
  end

  it "returns an alphabetical list of students being graded" do
    student = create(:user, last_name: 'Zed')
    student.courses << @course
    student2 = create(:user, last_name: 'Alpha')
    student2.courses << @course
    @course.students_being_graded.should eq([student2,student])
  end
end
