# frozen_string_literal: true

# == Schema Information
#
# Table name: diagnostic_responses
#
#  id                          :uuid             not null, primary key
#  diagnostic_survey_id        :uuid             not null
#  team_diagnostic_question_id :uuid             not null
#  locale                      :string           not null
#  response                    :text             not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
require 'rails_helper'

RSpec.describe DiagnosticResponse, type: :model do
  include_context 'users'
  include_context 'team_diagnostics'
  include_context 'diagnostic_surveys'

  describe 'validations' do
    let(:team_diagnostic_question) { teamdiagnostic_deployed.team_diagnostic_questions.rating.first }
    let(:team_diagnostic_question2) { teamdiagnostic_deployed.team_diagnostic_questions.rating.last }
    let(:diagnostic_survey) do
      create(:diagnostic_survey, participant:, team_diagnostic: teamdiagnostic_deployed, state: 'active')
      teamdiagnostic_deployed
      teamdiagnostic_deployed.reload
      teamdiagnostic.diagnostic_surveys.first
    end
    let(:diagnostic_response) { build(:diagnostic_response, diagnostic_survey:, team_diagnostic_question:) }
    let(:diagnostic_response2) { build(:diagnostic_response, diagnostic_survey:, team_diagnostic_question:) }

    it 'should only be creatable or editable if the diagnostic survey is not active' do
      assert(diagnostic_response.diagnostic_survey.active?)
      assert(diagnostic_response.save)
      assert(diagnostic_response.diagnostic_survey.active?)
      assert(diagnostic_response.save)
      diagnostic_survey.state = 'pending'
      diagnostic_survey.save!
      refute(diagnostic_response2.save)
      diagnostic_response.reload
      diagnostic_response.response = 'new response'
      refute(diagnostic_response.save)
    end
  end
end
