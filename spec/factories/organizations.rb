# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id          :uuid             not null, primary key
#  name        :string
#  slug        :string
#  domain      :string
#  description :text
#  active      :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :organization do
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
