# frozen_string_literal: true

# == Schema Information
#
# Table name: report_templates
#
#  id            :uuid             not null, primary key
#  tenant_id     :uuid             not null
#  diagnostic_id :uuid             not null
#  name          :string           not null
#  state         :string           default("draft"), not null
#  version       :integer          default(1), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :report_template do
    tenant { Tenant.default_tenant || create(:default_tenant) }
    diagnostic { create(:diagnostic) }
    sequence(:name) { |n| "Report Template #{n}" }
    state { 'published' }
    version { 1 }
  end
end
