# frozen_string_literal: true

# == Schema Information
#
# Table name: participants
#
#  id                 :uuid             not null, primary key
#  team_diagnostic_id :uuid             not null
#  state              :string           default("approved"), not null
#  email              :string           not null
#  phone              :string
#  title              :string
#  first_name         :string           not null
#  last_name          :string           not null
#  locale             :string           not null
#  timezone           :string           not null
#  notes              :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  metadata           :json
#
FactoryBot.define do
  factory :participant do
    team_diagnostic { create(:team_diagnostic) }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    title { Faker::Name.prefix }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    locale { ApplicationTranslation.select('distinct(locale)').order('RANDOM()').limit(1).pluck(:locale).first || 'en' }
    timezone { ActiveSupport::TimeZone::MAPPING.values[rand(150)] }
    notes { Faker::Lorem.paragraph }
  end
end
