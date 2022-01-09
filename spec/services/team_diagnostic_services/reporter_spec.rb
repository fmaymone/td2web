# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamDiagnosticServices::Reporter do
  include_context 'team_diagnostics'
  include_context 'report_templates'

  let(:team_diagnostic) { teamdiagnostic_completed }

  describe 'initialization' do
    it 'should initialize the service' do
      service = TeamDiagnosticServices::Reporter.new(team_diagnostic)
      expect(service.team_diagnostic).to eq(team_diagnostic)
    end
    it 'throws an error if a team diagnostic is not provided' do
      expect do
        service = TeamDiagnosticServices::Reporter.new(true)
      end.to raise_error
    end
  end

  describe 'calling the service' do
    let(:service) { service = TeamDiagnosticServices::Reporter.new(team_diagnostic) }
    describe 'with options'
    describe 'without page options' do
      it 'generates a report' do
        Report.destroy_all
        report_count = Report.count
        service.call
        expect(Report.count).to eq(report_count + 1)
        binding.pry; true
      end
      it 'cancels all existing/running reports before running a new report'
    end
  end
end
