# frozen_string_literal: true

# == Schema Information
#
# Table name: invitations
#
#  id                 :uuid             not null, primary key
#  tenant_id          :uuid
#  active             :boolean          default(TRUE)
#  token              :string
#  grantor_id         :uuid
#  grantor_type       :string
#  entitlements       :jsonb
#  email              :string
#  description        :text
#  redirect           :string
#  locale             :string           default("en")
#  i18n_key           :string
#  claimed_at         :datetime
#  claimed_by_user_id :uuid
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
FactoryBot.define do
  factory :invitation do
    tenant { Tenant.default_tenant || create(:default_tenant) }
    grantor { build(:user).save }
    entitlements do
      [
        {
          'id' => create(:entitlement).id,
          'quota' => 1
        }
      ]
    end
    email { 'me@example.com' }
    description { 'MyText' }
    i18n_key { 'MyString' }
    claimed_at { DateTime.now }
  end
end
