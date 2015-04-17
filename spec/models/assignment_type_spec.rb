# spec/models/assignment_type_spec.rb

describe AssignmentType do

  #simple validations
  it "is valid with a name, and a setting for the predictor" do
    assignment_type = AssignmentType.new(
      name: "Level 1", points_predictor_display: "Checkbox" )
    expect(assignment_type).to be_valid
  end

  it "is invalid without a name" do
    expect(AssignmentType.new(name: nil)).to have(1).errors_on(:name)
  end

  it "is invalid without a predictor setting" do
    pending
    expect(AssignmentType.new(points_predictor_display: nil)).to have(1).errors_on(:points_predictor_display)
  end

end
