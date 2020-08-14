# frozen_string_literal: true

# == Schema Information
#
# Table name: tenants
#
#  id          :uuid             not null, primary key
#  name        :string
#  slug        :string
#  domain      :string
#  description :text
#  active      :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  locale      :string           default("en")
#
FactoryBot.define do
  factory :tenant do
    sequence :name do |n|
      Faker::Company.name + "-#{n}"
    end
    sequence :slug do |n|
      Faker::Alphanumeric.alpha(number: 5) + "-#{n}"
    end
    sequence :domain do |n|
      Faker::Internet.domain_name + "#{n}.com"
    end
    description { Faker::Lorem.paragraph }
    active { true }
  end
end
