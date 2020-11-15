# frozen_string_literal: true

# == Schema Information
#
# Table name: diagnostics
#
#  id          :uuid             not null, primary key
#  slug        :string           not null
#  name        :string           not null
#  description :text             not null
#  active      :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :diagnostic do
    sequence(:slug) { |n| "TDA#{n}" }
    name { 'Team Diagnostic' }
    description { 'The Team Diagnostic' }
    active { true }
  end
end
