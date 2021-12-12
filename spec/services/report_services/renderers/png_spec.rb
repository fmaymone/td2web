# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportServices::Renderers::Png do
  include_context 'team_diagnostics'
  include_context 'report_templates'
  include_context 'report_template_pages_for_renderers'

  let(:team_diagnostic) { completed_teamdiagnostic }
  let(:locale) { 'en' }
  let(:report_options) { {} }
  let(:report) { team_diagnostic.init_report(options: report_options) }
  let(:service) { ReportServices::Renderers::Png.new(report: report, locale: locale) }

  it 'creates png files for all charts for all teamdiagnostic locales' do
    locales = report.team_diagnostic.all_locales
    charts = ReportServices::DataGenerator::GENERATORS
    expect(charts.size).to eq 8
    assert(locales.size > 1)
    service.call
    service.report.reload
    png_files = service.png_files
    expect(png_files.size).to eq(charts.size)
    expect(png_files.map { |f| f[:format] }.uniq).to eq(['image/png'])
  end
end
