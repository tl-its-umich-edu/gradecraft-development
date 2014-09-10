require 'faker'

FactoryGirl.define do
  factory :course do
    name 'Intro to Political Theory'
    courseno 'POLSCI101'
    team_setting false
    max_group_size 5
    min_group_size 2
    team_score_average false
  end
end
