FactoryGirl.define do
  factory :badge do
    association :course
    name { Faker::Internet.domain_word }
    point_total { rand(200) + 100 }
    visible { true }
  end
end
