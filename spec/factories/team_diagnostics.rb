# frozen_string_literal: true

# == Schema Information
#
# Table name: team_diagnostics
#
#  id                  :uuid             not null, primary key
#  organization_id     :uuid             not null
#  user_id             :uuid             not null
#  team_diagnostic_id  :uuid
#  diagnostic_id       :uuid             not null
#  state               :string           default("setup"), not null
#  locale              :string           default("en"), not null
#  timezone            :string           not null
#  name                :string           not null
#  description         :text             not null
#  situation           :text
#  functional_area     :string           not null
#  team_type           :string           not null
#  show_members        :boolean          default(TRUE), not null
#  contact_phone       :string           not null
#  contact_email       :string           not null
#  alternate_email     :string
#  cover_letter        :text             not null
#  reminder_letter     :text             not null
#  cancellation_letter :text             not null
#  due_at              :datetime         not null
#  completed_at        :datetime
#  deployed_at         :datetime
#  auto_deploy_at      :datetime
#  reminder_at         :datetime
#  reminder_sent_at    :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  wizard              :integer          default(1), not null
#
FactoryBot.define do
  factory :team_diagnostic do
    organization { create(:organization) }
    user { create(:user, tenant: Tenant.default_tenant) }
    # reference_diagnostic { nil }
    diagnostic { create(:diagnostic) }
    # state { 'setup' }
    # locale { 'en' }
    timezone { 'Pacific Time (US & Canada)' }
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    situation { Faker::Lorem.paragraph }
    functional_area { 'todo' }
    team_type { 'todo' }
    show_members { true }
    contact_phone { Faker::PhoneNumber.cell_phone }
    contact_email { Faker::Internet.email }
    alternate_email { Faker::Internet.email }
    cover_letter { Faker::Lorem.paragraphs(number: 5) }
    reminder_letter { Faker::Lorem.paragraphs(number: 5) }
    cancellation_letter { Faker::Lorem.paragraphs(number: 5) }
    due_at { reminder_at + 1.day }
    # completed_at { Faker::Date.backward }
    # deployed_at { Faker::Date.backward }
    auto_deploy_at { Faker::Date.backward }
    reminder_at { Faker::Date.forward }
    # reminder_sent_at { Faker::Date.backward }
  end
end