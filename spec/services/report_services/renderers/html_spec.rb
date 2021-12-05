# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportServices::Renderers::Html do
  include_context 'team_diagnostics'
  include_context 'report_templates'
  include_context 'report_template_pages'

  let(:team_diagnostic) { completed_teamdiagnostic }
  let(:locale) { 'en' }
  let(:report_options) { {} }
  let(:report) { team_diagnostic.init_report(options: report_options) }

  let(:service) do
    ReportServices::Renderers::Html.new(report: report, locale: locale)
  end

  it 'can be initialized' do
    service
  end

  it 'returns html output' do
    service.report.report_files.destroy_all
    service.report.reload

    output = service.generate(locale)
    assert(output.is_a?(String))
    expect(output).to match('Page 1')
    expect(output).to match('Page 2')
    expect(output).to match('Begin Layout')
    expect(output).to match('End Layout')
  end

  it 'interpolates template data' do
    output = service.generate(locale)
    refute(output.match?('Liquid error'))
    expect(output).to match("diagnostic_type: #{report.team_diagnostic.diagnostic.name}")
    expect(output).to match("team_name: #{report.team_diagnostic.name}")
    expect(output).to match("locale: #{locale}")
    expect(output).to match('Out as page 1')
    expect(output).to match('Out as page 2')
  end

  it 'generates an html file' do
    service.report.report_files.destroy_all
    service.report.reload

    service.call
    report.report_files.reload
    assert(report.report_files.attached?)
    html_attachment = report.report_files.last.blob.download
    assert(html_attachment.match?('Team Diagnostic Report'))
    assert(service.files.first[:name].match 'Full Report HTML')
  end

  it 'orders pages as specified by report options' do
    service.report.report_files.destroy_all
    service.report.options = { page_order: [1, 2] }
    service.report.save
    service.report.reload
    service.call
    html_attachment = report.report_files.last.blob.download
    assert(html_attachment.match?('Team Diagnostic Report'))
    assert(service.files.first[:name].match 'Full Report HTML')
    page_1_index = html_attachment.index('Page 1')
    page_2_index = html_attachment.index('Page 2')
    assert(page_2_index > page_1_index)

    service.report.report_files.destroy_all
    service.report.options = { page_order: [2, 1] }
    service.report.save!
    service.report.reload
    service.call
    html_attachment = report.report_files.last.blob.download
    assert(html_attachment.match?('Team Diagnostic Report'))
    assert(service.files.first[:name].match 'Full Report HTML')
    page_1_index = html_attachment.index('Page 1')
    page_2_index = html_attachment.index('Page 2')
    assert(page_2_index < page_1_index)
  end
end
