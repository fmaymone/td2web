# frozen_string_literal: true

RSpec.shared_context 'report_templates', shared_context: :metadate do
  include_context 'diagnostics'
  include_context 'report_template_pages'

  # Report template page test data need to match this template's name (db/seed/report_template_pages.yml)
  let(:teamdiagnostic_report_template) do
    diagnostic = teamdiagnostic.diagnostic
    name = 'TDA Diagnostic Report (en)'
    ReportTemplate.where(diagnostic:, name:).first ||
      create(:report_template, diagnostic: teamdiagnostic.diagnostic, name:)
  end

  let(:completed_teamdiagnostic_report_template) { create(:report_template, diagnostic: completed_teamdiagnostic.diagnostic) }

  before(:each) { teamdiagnostic_report_template }
end
