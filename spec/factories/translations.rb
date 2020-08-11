# frozen_string_literal: true

FactoryBot.define do
  factory :translation do
    locale { create(:globalize_language).locale }
    sequence :key do |n|
      Faker::Alphanumeric.alpha(number: 5) + "-#{n}"
    end
    value { Faker::Lorem.sentence }
  end
end
