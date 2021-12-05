# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportServices::Renderers::Pdf do
  include_context 'team_diagnostics'
  include_context 'report_templates'
  include_context 'report_template_pages'

  let(:team_diagnostic) { completed_teamdiagnostic }
  let(:locale) { 'en' }

  let(:report_options) { {} }
  let(:report) { team_diagnostic.init_report(options: report_options) }

  let(:service) do
    ReportServices::Renderers::Pdf.new(report: report, locale: locale)
  end

  it 'can be intialized' do
    service
  end

  it 'returns PDF output' do
    service.call
    pdf_file = service.files.select { |f| f[:name].match ReportServices::Renderers::Pdf::TITLE }
    assert(pdf_file.present?)
  end

  it 'returns a format' do
    expect(service.format).to eq(:pdf)
  end
end
