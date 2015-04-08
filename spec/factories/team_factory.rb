FactoryGirl.define do
  factory :team do
    association :course
    name { Faker::Lorem.word }
  end
end
