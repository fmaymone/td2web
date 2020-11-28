# frozen_string_literal: true

RSpec.shared_context 'participants', shared_context: :metadate do
  include_context 'users'
  include_context 'team_diagnostics'

  let(:participant) do
    create(:participant,
           team_diagnostic: teamdiagnostic,
           title: 'Mr.',
           first_name: 'Wol',
           last_name: 'Smoth',
           locale: 'en',
           timezone: 'UTC',
           email: 'wol.smoth@example.com')
  end
end
