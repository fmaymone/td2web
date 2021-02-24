# frozen_string_literal: true

FactoryBot.define do
  factory :diagnostic_response do
    diagnostic_survey { create(:diagnostic_survey) }
    team_diagnostic_question { create(:team_diagnostic_question) }
    locale { diagnostic_survey.locale }
    response { 'yeah' }
  end
end
