FactoryGirl.define do
  factory :submission do
    association :assignment
    text_comment "needs a link, file, or text comment to be valid"

    factory :graded_submission do
      association :grade, factory: :scored_grade
    end
  end
end

