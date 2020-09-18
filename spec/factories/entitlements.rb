# frozen_string_literal: true

# == Schema Information
#
# Table name: entitlements
#
#  id          :uuid             not null, primary key
#  account     :boolean          default(TRUE), not null
#  active      :boolean          default(TRUE), not null
#  role_id     :uuid             not null
#  reference   :string           not null
#  slug        :string           not null
#  description :text
#  quota       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :entitlement do
    account { true }
    active { true }
    role_id { Role.facilitator&.id || create(:facilitator_role).id }
    reference { AppContext.list[rand(AppContext.list.size - 1)] }
    description { Faker::Lorem.paragraph }
    quota { Faker::Number.within(range: 1...9999) }
    sequence(:slug) { |n| Faker::Lorem.sentence + n.to_s }
  end
end
