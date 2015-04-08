FactoryGirl.define do
  factory :challenge_file do
    challenge
    filename "test_file.rb"
    file { fixture_file('test_image.jpg', 'img/jpg') }
  end
end
