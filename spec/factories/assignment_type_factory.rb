FactoryGirl.define do
  factory :assignment_type do
    name { Faker::Lorem.word }
    association :course
    points_predictor_display 'Fixed'
  end
end
