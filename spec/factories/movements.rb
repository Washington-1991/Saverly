FactoryBot.define do
  factory :movement do
    user
    date { Date.today }
    amount { 100.0 }
    description { "Test movement" }
    source_account { nil }
    destination_account { nil }
  end
end
