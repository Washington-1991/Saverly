FactoryBot.define do
  factory :account do
    user
    sequence(:name) { |n| "Account #{n}" }
    kind { "asset" }
    current_balance { 0.0 }
  end

  trait :asset do
    kind { "asset" }
  end

  trait :expense do
    kind { "expense" }
  end

  trait :income do
    kind { "income" }
  end
end
