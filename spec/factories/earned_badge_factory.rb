FactoryGirl.define do
  factory :earned_badge do
    association :badge
    association :course
    association :student, factory: :user
    # student_visible { true } # undefined method `student_visible='
  end
end
