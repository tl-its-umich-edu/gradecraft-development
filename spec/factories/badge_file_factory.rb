FactoryGirl.define do
  factory :badge_file do
    association :badge
    filename "test_file.rb"
    file { fixture_file('test_image.jpg', 'img/jpg') }
  end
end
