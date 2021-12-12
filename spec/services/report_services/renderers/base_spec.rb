# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportServices::Renderers::Base do
  include_context 'team_diagnostics'
  include_context 'report_templates'

  let(:team_diagnostic) { completed_teamdiagnostic }
  let(:report_options) { {} }
  let(:report) { team_diagnostic.init_report(options: report_options) }

  it 'can be initialized and called' do
    locale = 'en'
    service = ReportServices::Renderers::Base.new(report: report, locale: locale)
    assert(service.call)
  end
end
