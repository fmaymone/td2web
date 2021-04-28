# frozen_string_literal: true

module ReportServices
  module Renderers
    # HTML/Liquid report renderer
    class Png < Base
      ID = :png
      TITLE = 'Chart Image'
      VERSION = 1
      CONTENT_TYPE = 'image/png'

      def call
        super
        build
      end

      def format
        ID
      end

      def title(name = nil)
        [name, TITLE].compact.join(' ')
      end

      def chart_names
        @chart_names ||= ReportServices::DataGenerator::GENERATORS.map { |g| g.to_s.split('::').last }
                                                                  .compact.uniq
      end

      def png_files
        files.select { |f| f[:format] == CONTENT_TYPE }
      end

      private

      def build
        locales.each do |locale|
          build_for_locale(locale)
        end
      end

      def build_for_locale(locale)
        html_service = ReportServices::Renderers::Html.new(report: @report, locale: locale, options: @options)
        html_data = html_service.generate(locale)
        chart_names.each do |chart_name|
          diagnostic_name = report.team_diagnostic.name.humanize
          file_chart_name = chart_name.titleize
          filename = "#{diagnostic_name}-#{file_chart_name}---#{locale}---#{Time.now.strftime('%Y%m%d')}.png"
          image_service = IMGKit.new(html_data, quality: 95)
          chart_file = StringIO.new(chart_css(chart_name))
          image_service.stylesheets << chart_file
          png_file = StringIO.new(image_service.to_png)
          @report.report_files.attach(io: png_file, filename: filename, content_type: CONTENT_TYPE)
        end
      end

      def chart_css(chart_name)
        <<~EOCSS
          section { display: none; }
          ##{chart_name} { display: block; }
        EOCSS
      end
    end
  end
end
