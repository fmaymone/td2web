# frozen_string_literal: true

# == Schema Information
#
# Table name: grants
#
#  id             :uuid             not null, primary key
#  active         :boolean          default(TRUE)
#  user_id        :uuid             not null
#  reference      :string           not null
#  entitlement_id :uuid             not null
#  grantor_id     :uuid
#  grantor_type   :string
#  quota          :integer
#  description    :text
#  staff_notes    :text
#  granted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
FactoryBot.define do
  factory :grant do
    active { true }
    reference { AppContext.list[rand(AppContext.list.size - 1)] }
    entitlement { create(:entitlement, reference:) }
    description { Faker::Lorem.paragraph }
    staff_notes { Faker::Lorem.paragraph }
    quota { Faker::Number.within(range: 1...9999) }
    granted_at { DateTime.now - 1.hour }
  end
end
