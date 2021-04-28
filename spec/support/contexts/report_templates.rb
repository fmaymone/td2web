# frozen_string_literal: true

RSpec.shared_context 'report_templates', shared_context: :metadate do
  include_context 'diagnostics'

  let(:teamdiagnostic_report_template) { create(:report_template, diagnostic: teamdiagnostic.diagnostic) }
  let(:completed_teamdiagnostic_report_template) { create(:report_template, diagnostic: completed_teamdiagnostic.diagnostic) }

  before(:each) { teamdiagnostic_report_template }
end
