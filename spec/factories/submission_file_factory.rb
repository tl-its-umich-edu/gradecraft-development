FactoryGirl.define do
  factory :submission_file do
    submission
    filename "test_file.rb"
    file { fixture_file('test_image.jpg', 'img/jpg') }
  end
end
