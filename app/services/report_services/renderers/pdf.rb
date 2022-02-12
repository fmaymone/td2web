# frozen_string_literal: true

module ReportServices
  module Renderers
    # PDF report renderer
    # Converts HTML report to PDF
    class Pdf < Base
      ID = :pdf
      TITLE = 'Full Report PDF'
      VERSION = 1
      CONTENT_TYPE = 'application/pdf'

      def call
        super
        build
      end

      def build
        locales.each do |locale|
          build_for_locale(locale)
        end
      end

      def build_for_locale(locale)
        configure_generator_for_locale(locale)
        filename = "#{report.team_diagnostic.name}-#{title}---#{locale}---#{Time.now.strftime('%Y%m%d%H%M')}.pdf"
        pdf_data = StringIO.new(generate(locale))
        @report.report_files.attach(io: pdf_data, filename:, content_type: CONTENT_TYPE)
      end

      def format
        ID
      end

      def title
        TITLE
      end

      def generate(locale)
        html_service = ReportServices::Renderers::Html.new(report: @report, locale:, options: @options)
        html_data = html_service.generate(locale)

        pdf_service = PDFKit.new(html_data)
        pdf_service.to_pdf
      end

      private

      def configure_generator_for_locale(locale)
        page_size = (locale.to_s == 'en' ? 'letter' : 'A4')
        PDFKit.configure do |config|
          config.default_options = {
            page_size:,
            orientation: 'Landscape',
            print_media_type: true,
            margin_top: '0.1cm',
            margin_bottom: '0.1cm',
            margin_left: '0.1cm',
            margin_right: '0.1cm'
          }
        end
      end
    end
  end
end
