# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id          :uuid             not null, primary key
#  slug        :string           not null
#  name        :string           not null
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :role do
    sequence :name, &:to_s
    sequence :slug, &:to_s
    description { Faker::Lorem.sentence }
    factory :admin_role do
      name { 'Administrator' }
      slug { Role::ADMIN_ROLE }
    end
    factory :staff_role do
      name { 'Staff' }
      slug { Role::STAFF_ROLE }
    end
    factory :facilitator_role do
      name { 'Facilitator' }
      slug { Role::FACILITATOR_ROLE }
    end
  end
end
