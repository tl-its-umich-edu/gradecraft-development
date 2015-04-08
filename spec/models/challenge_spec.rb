#challenge_spec.rb
require 'spec_helper'

describe Challenge do

  before do
    @challenge = build(:challenge)
  end

  subject { @challenge }

  it { should respond_to("name")}
  it { should respond_to("description")}
  it { should respond_to("point_total")}
  it { should respond_to( "due_at")}
  it { should respond_to("course_id")}
  it { should respond_to("points_predictor_display")}
  it { should respond_to("visible")}
  it { should respond_to("accepts_submissions")}
  it { should respond_to("release_necessary")}
  it { should respond_to("created_at")}
  it { should respond_to("updated_at")}
  it { should respond_to("open_at")}
  it { should respond_to("mass_grade")}
  it { should respond_to("mass_grade_type")}
  it { should respond_to("levels")}
  it { should respond_to("media")}
  it { should respond_to("thumbnail")}
  it { should respond_to("media_credit")}
  it { should respond_to("media_caption")}

  it { should be_valid }

  it "is invalid without a name" do
    @challenge.name = nil
    expect(@challenge).to have(1).errors_on(:name)
  end

  it "is invalid without a course" do
    @challenge.course = nil
    expect(@challenge).to have(1).errors_on(:course)
  end
end
