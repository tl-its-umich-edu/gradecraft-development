require 'faker'

FactoryGirl.define do

  factory :user do
    email { Faker::Internet.email }
    first_name 'Albus'
    last_name 'Dumbledore'
    username 'dumbledore'
    password 'secret'
    password_confirmation 'secret'
    after :create do |u|
        u.courses << FactoryGirl.create(:course)
    end

    factory :admin do
      role 'admin'
    end

    factory :gsi do
      role 'gsi'
    end

    factory :instructor do
      role 'instructor'
    end 

    factory :student do
      role 'student'
    end

  end  
end