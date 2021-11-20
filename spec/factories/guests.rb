# frozen_string_literal: true

FactoryBot.define do
  factory :guest do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::Number.number(digits: 12) }
  end
end
