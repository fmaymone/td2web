# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosticResponse, type: :model do
  include_context 'users'
  include_context 'team_diagnostics'
  include_context 'diagnostic_surveys'

  describe 'validations' do
    let(:team_diagnostic_question) { teamdiagnostic_deployed.team_diagnostic_questions.rating.first }
    let(:team_diagnostic_question2) { teamdiagnostic_deployed.team_diagnostic_questions.rating.last }
    let(:diagnostic_survey) do
      create(:diagnostic_survey, participant: participant, team_diagnostic: teamdiagnostic_deployed, state: 'active')
      teamdiagnostic_deployed
      teamdiagnostic_deployed.reload
      teamdiagnostic.diagnostic_surveys.first
    end
    let(:diagnostic_response) { build(:diagnostic_response, diagnostic_survey: diagnostic_survey, team_diagnostic_question: team_diagnostic_question) }
    let(:diagnostic_response2) { build(:diagnostic_response, diagnostic_survey: diagnostic_survey, team_diagnostic_question: team_diagnostic_question) }

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