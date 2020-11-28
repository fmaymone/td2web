# frozen_string_literal: true

# == Schema Information
#
# Table name: team_diagnostic_questions
#
#  id                 :uuid             not null, primary key
#  slug               :string           default("OEQ"), not null
#  team_diagnostic_id :uuid
#  body               :string           not null
#  body_positive      :string
#  category           :integer          default("NoCategory"), not null
#  question_type      :integer          default("Open-Ended"), not null
#  factor             :integer          default("NoFactor"), not null
#  matrix             :integer          default(0), not null
#  negative           :boolean          default(FALSE)
#  active             :boolean          default(TRUE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
FactoryBot.define do
  factory :team_diagnostic_question do
    team_diagnostic { create(:team_diagnostic) }
    body { Faker::Lorem.sentence }
    body_positive { Faker::Lorem.sentence }
    category { 'Productivity' }
    question_type { 'Rating' }
    factor { 'Resources' }
    sequence(:matrix)
    negative { true }
  end
end
