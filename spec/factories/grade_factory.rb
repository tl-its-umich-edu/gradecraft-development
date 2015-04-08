FactoryGirl.define do
  factory :grade do
    association :course
    association :assignment
    association :student, factory: :user

    factory :scored_grade do
      #TODO: add minimum requirements to pass submission.graded?
      score { Faker::Number.number(5) }
    end
  end
end
