# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamDiagnosticServices::Reporter do
  include_context 'team_diagnostics'

  let(:team_diagnostic) { completed_teamdiagnostic }

  describe 'initialization' do
    it 'should initialize the service' do
      service = TeamDiagnosticServices::Reporter.new(team_diagnostic)
      expect(service.team_diagnostic).to eq(team_diagnostic)
    end
  end
end
