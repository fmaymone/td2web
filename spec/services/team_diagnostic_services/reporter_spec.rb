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
        TeamDiagnosticServices::Reporter.new(true)
      end.to raise_error
    end
  end

  describe 'calling the service' do
    before do
      Report.destroy_all
    end
    let(:service) { TeamDiagnosticServices::Reporter.new(team_diagnostic) }
    describe 'with options'
    describe 'without page options' do
      it 'generates a report' do
        report_count = Report.count
        service.call
        expect(Report.count).to eq(report_count + 1)
        #service.team_diagnostic.reload
        #expect(service.team_diagnostic.reports.count).to eq(1)
        #report = service.team_diagnostic.reports.last
        #files = report.rendered_files
        #binding.pry; true
      end
      it 'cancels all existing/running reports before running a new report' do
        service.call
        report = Report.last
        report.state = 'running'
        report.save
        service = TeamDiagnosticServices::Reporter.new(team_diagnostic)
        service.call
        report.reload
        assert(report.rejected?)
      end
    end
    describe 'report status' do
      it 'should return :pending if a report has not been created' do
        expect(service.status).to eq(:pending)
      end
      it 'should return :stalled if a report stalled during processing' do
        service.call
        report = Report.last
        report.state = 'running'
        report.updated_at = 1.day.ago
        report.save(touch: false)
        service = TeamDiagnosticServices::Reporter.new(team_diagnostic)
        expect(service.status).to eq(:stalled)
      end
      it 'should return :running if the report is still running but not stalled' do
        service.call
        report = Report.last
        report.state = 'running'
        report.save
        service = TeamDiagnosticServices::Reporter.new(team_diagnostic)
        expect(service.status).to eq(:running)
      end
      it 'should return :completed if the report completed successfully' do
        service.call
        expect(service.status).to eq(:completed)
      end
      it 'should return css classes' do
        service.call
        expect(service.status_css_class).to eq('success')
      end
      it 'will return whether the report may be reset' do
        refute(service.may_reset?)
        service.call
        assert(service.may_reset?)
      end
    end
  end
end
