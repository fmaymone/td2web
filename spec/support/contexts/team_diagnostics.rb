# frozen_string_literal: true

RSpec.shared_context 'team_diagnostics', shared_context: :metadate do
  include_context 'users'
  include_context 'organizations'
  include_context 'diagnostics'

  let(:teamdiagnostic) { create(:team_diagnostic, user_id: facilitator.id, organization_id: organization.id, diagnostic_id: team_diagnostic.id) }
  let(:teamdiagnostic_participants) do
    Array.new(4) do
      ParticipantServices::Creator.new(
        user: facilitator, team_diagnostic: teamdiagnostic, params: attributes_for(:participant, team_diagnostic: teamdiagnostic)
      ).call
    end
  end
end
