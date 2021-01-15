# frozen_string_literal: true

RSpec.shared_context 'participants', shared_context: :metadate do
  include_context 'users'
  include_context 'team_diagnostics'
  include_context 'translations'

  let(:participant) do
    translations
    create(:participant,
           team_diagnostic: teamdiagnostic,
           title: 'Mr.',
           first_name: 'Wol',
           last_name: 'Smoth',
           locale: 'en',
           timezone: 'UTC',
           email: 'wol.smoth@example.com')
  end

  let(:teamdiagnostic_participants) do
    translations
    create_list(:participant, 5, team_diagnostic: teamdiagnostic)
  end
end
