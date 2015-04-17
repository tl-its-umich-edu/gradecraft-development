FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Internet.user_name }
    email { Faker::Internet.email }
    salt "asdasdastr4325234324sdfds"
    crypted_password { Sorcery::CryptoProviders::BCrypt.encrypt("secret", salt) }
  end
end
