# frozen_string_literal: true

RSpec.shared_context 'diagnostic_surveys', shared_context: :metadate do
  include_context 'users'
  include_context 'organizations'
  include_context 'diagnostics'

  let(:participant) { create(:participant, team_diagnostic: teamdiagnostic, state: :approved) }
  let(:diagnostic_survey) { create(:diagnostic_survey, participant:, team_diagnostic: teamdiagnostic) }
end
