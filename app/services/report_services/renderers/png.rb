# frozen_string_literal: true

module ReportServices
  module Renderers
    # HTML/Liquid report renderer
    class Png < Base
      ID = :png
      TITLE = 'Chart Image'
      VERSION = 1
      CONTENT_TYPE = 'image/png'
      OMIT_CHARTS = ['OpenEndedQuestions'].freeze

      def call
        super
        build
      end

      def format
        ID
      end

      def title(chart_name = nil)
        diagnostic_name = report.team_diagnostic.name.humanize
        file_chart_name = chart_name.titleize
        "#{diagnostic_name}-#{file_chart_name}"
      end

      def chart_names
        @chart_names ||= ReportServices::DataGenerator::GENERATORS.map { |g| g.to_s.split('::').last }
                                                                  .compact.uniq - OMIT_CHARTS
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
        html_service = ReportServices::Renderers::Html.new(report: @report, locale:, options: @options)
        html_data = html_service.generate(locale)

        chart_names.each do |chart_name|
          html_copy = html_data.dup
          filename = "#{title(chart_name)}---#{locale}---#{Time.now.strftime('%Y%m%d%H%M')}.png"

          image_service = IMGKit.new(html_copy, quality: 95)
          chart_css_file = StringIO.new(chart_css(chart_name))
          Rails.logger.info 'chart_css_file'
          content = chart_css_file.read
          Rails.logger.info content
          Rails.logger.info 'chart_css_file'
          image_service.stylesheets = []
          image_service.stylesheets << chart_css_file
          png_file = StringIO.new(image_service.to_png)

          begin
            blob = ActiveStorage::Blob.create_and_upload!(io: png_file, filename:, content_type: CONTENT_TYPE)
            @report.report_files.attach(blob)
          rescue StandardError => e
            # Handle the error accordingly
            Rails.logger.error "Failed to create and upload blob for #{filename}: #{e.message}"
            # You can also notify a monitoring service, retry the operation, or take other appropriate actions here
          ensure
            Rails.logger.info 'Finished png generation'
            png_file.rewind
          end
        end
      end

      # def chart_css(chart_name)
      # <<~EOCSS
      # section { display: none; }
      # ##{chart_name} { display: block; }
      # ##{chart_name} header, ##{chart_name} footer { display: none;}
      # EOCSS
      # end

      def chart_css(chart_name)
        <<~EOCSS
          section.report_page {
            border: none;
            height: auto;
            width: auto;
            margin: 0;
            padding: 0;
          }
          section:not(##{chart_name}) { display: none; }
          ##{chart_name} { display: block; }
          ##{chart_name} header, ##{chart_name} footer { display: none;}
        EOCSS
      end
    end
  end
end
