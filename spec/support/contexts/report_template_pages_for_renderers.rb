# frozen_string_literal: true

RSpec.shared_context 'report_template_pages_for_renderers', shared_context: :metadate do
  require_relative '../../../db/seed/report_template_pages'

  let(:report_template_pages_seed_data_filepath) do
    File.join(Rails.root, 'db', 'seed', 'report_template_pages_for_test.yml')
  end
  let(:report_template_pages_seed_data) { Seeds::ReportTemplatePages.new(filename: report_template_pages_seed_data_filepath).call }

  before(:each) do
    ReportTemplatePage.destroy_all
    report_template_pages_seed_data
  end
end
