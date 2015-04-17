FactoryGirl.define do
  factory :course do
    name { Faker::Internet.domain_word }
    courseno { Faker::Internet.domain_word }

    factory :course_accepting_groups do
      min_group_size 2
      max_group_size 10
    end
  end
end
