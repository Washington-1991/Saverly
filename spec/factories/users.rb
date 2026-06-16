FactoryBot.define do
  factory :user do
    username { Faker::Internet.unique.username }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
