FactoryGirl.define do
  factory :rubric do
    association :assignment

    factory :rubric_with_metrics do
      after(:create) do |rubric|
        (0..5).each {|i| create(:metric, rubric: rubric, order: i)}
      end
    end
  end
end
