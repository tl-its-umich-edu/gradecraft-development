FactoryGirl.define do
  factory :group do
    before(:create) do |group|
      (0..3).each { group.students << create(:user) }
      group.assignments << create(:assignment)
    end
    association :course, factory: :course_accepting_groups
    name { Faker::Lorem.word }
    approved "Pending"
  end
end
