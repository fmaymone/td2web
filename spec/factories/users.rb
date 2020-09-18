# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  tenant_id              :uuid             not null
#  role_id                :uuid             not null
#  locale                 :string           default("en"), not null
#  timezone               :string           default("Pacific Time (US & Canada)"), not null
#  username               :string           not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
FactoryBot.define do
  factory :user, class: User do
    tenant { Tenant.default_tenant || create(:default_tenant) }
    role { Role.facilitator || create(:role, name: 'Facilitator', slug: 'facilitator') }
    username { Faker::Name.name }
    email { Faker::Internet.email }
    locale { 'en' }
    timezone { 'Pacific Time (US & Canada)' }
    password { 'Password123.' }
    password_confirmation { 'Password123.' }
    # confirmed_at { DateTime.now }
    user_profile

    factory :admin_user do
      role { Role.admin || create(:admin_role) }
      username { 'administrator1' }
      email { 'administrator1@example.com' }
    end
  end
end
