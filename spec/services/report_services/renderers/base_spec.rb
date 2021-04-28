# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportServices::Renderers::Base do
  include_context 'team_diagnostics'
  include_context 'report_templates'
  include_context 'report_template_pages'

  let(:team_diagnostic) { completed_teamdiagnostic }

  before(:each) do
    team_diagnostic
    team_diagnostic.perform_report
    team_diagnostic.reload
  end

  it 'can be initialized' do
    locale = 'en'
    report = team_diagnostic.reports.rendering.last
    service = ReportServices::Renderers::Base.new(report: report, locale: locale)
    assert(service.call)
  end
end
