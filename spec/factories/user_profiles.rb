# frozen_string_literal: true

# == Schema Information
#
# Table name: user_profiles
#
#  id           :uuid             not null, primary key
#  user_id      :uuid
#  prefix       :string           default("")
#  first_name   :string           default("")
#  middle_name  :string           default("")
#  last_name    :string
#  suffix       :string           default("")
#  pronoun      :string           default("they")
#  country      :string
#  company      :string
#  department   :string
#  title        :string
#  ux_version   :integer          default(0)
#  consent      :jsonb
#  staff_notes  :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  phone_number :string           not null
#
FactoryBot.define do
  factory :user_profile, class: UserProfile do
    prefix { Faker::Name.prefix }
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.middle_name }
    last_name { Faker::Name.last_name }
    suffix { Faker::Name.suffix }
    phone_number { Faker::PhoneNumber.phone_number }
    pronoun { 'she' }
    country { 'US' }
    consent do
      {
        'eula' => '1',
        'eula_granted_at' => 1.day.ago,
        'cookies_required' => '1',
        'cookies_required_granted_at' => 1.day.ago
      }
    end
  end
end
