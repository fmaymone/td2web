# frozen_string_literal: true

# == Schema Information
#
# Table name: diagnostic_questions
#
#  id            :uuid             not null, primary key
#  slug          :string           not null
#  diagnostic_id :uuid
#  body          :string           not null
#  body_positive :string
#  category      :integer          not null
#  question_type :integer          not null
#  factor        :integer          not null
#  matrix        :integer          not null
#  negative      :boolean          default(FALSE)
#  active        :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :diagnostic_question do
    sequence(:slug) { |n| "slug#{n}" }
    diagnostic { create(:diagnostic) }
    body { Faker::Lorem.sentence }
    body_positive { Faker::Lorem.sentence }
    category { 'Productivity' }
    question_type { 'Rating' }
    factor { 'Resources' }
    sequence(:matrix)
    negative { true }
    active { true }
  end
end
