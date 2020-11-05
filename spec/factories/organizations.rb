# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id          :uuid             not null, primary key
#  tenant_id   :uuid             not null
#  name        :string           not null
#  description :text
#  url         :string           not null
#  industry    :integer          not null
#  revenue     :integer          not null
#  locale      :string           default("en"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :organization do
    tenant { Tenant.default_tenant || create(:default_tenant) }
    name { Faker::Company.name }
    description { Faker::Lorem.sentence }
    url { Faker::Internet.url }
    industry { 'Agriculture' }
    revenue { 'Non Profit Organization' }
    locale { 'en' }
  end
end
