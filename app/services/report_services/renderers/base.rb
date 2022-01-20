# frozen_string_literal: true

module ReportServices
  module Renderers
    # report renderer base class
    class Base
      DEFAULT_OPTIONS = { page_order: :default }.freeze
      LAYOUT_CONTENT_KEYWORD = '[[REPORT_CONTENT_HERE]]'

      class LayoutError < StandardError; end

      class RendererError < StandardError; end

      attr_reader :report, :template, :locale, :options

      # Initialize a Report renderer with locale and options
      #
      # example options: { page_order: [2,1,3],
      #                    css: "<style media='all'></style>" }
      #
      def initialize(report:, locale: nil, options: {})
        @report = report
        @template = report.report_template
        @locale = locale
        @options = options || @report.options || {}
      end

      def call
        true
      end

      def format
        nil
      end

      def files
        @report.report_files.map do |file|
          info = file.filename.to_s.split('---')
          file_name = info[0] || file.filename.to_s
          locale = info[1]
          {
            name: file_name,
            locale: locale,
            url: Rails.application.routes.url_helpers.url_for(file),
            format: file.content_type,
            date: file.created_at,
            object: file
          }
        end
      end

      def locales
        case @locale
        when nil, :all
          @report.team_diagnostic.all_locales.compact.uniq
        else
          [@locale]
        end
      end

      private

      def host_prefix
        Rails.application.routes.default_url_options[:host]
      end

      def page_scope(locale)
        unless @page_scope ||= nil
          @page_scope = @template.pages.locale(locale)
          @page_scope = @page_scope.format(format) if format
          @page_scope
        end
        @page_scope
      end

      def layout_page(locale)
        page_scope(locale).layout_page.last or raise(LayoutError, 'Diagnostic report template layout not found')
      end

      def content_pages(locale)
        pages = page_scope(locale).content_pages.order(index: :asc).each_with_object({}) do |obj, memo|
          memo[obj.index.to_s.to_sym] = obj
        end
        page_order(locale).map { |page_number| pages.fetch(page_number.to_s.to_sym, nil) }.compact
      end

      def page_order(locale)
        case effective_options[:page_order]
        when :default
          @report.options.fetch(:page_order,
                                (1..([1, page_scope(locale).content_pages.count].max))).to_a
        else
          effective_options[:page_order].to_a.uniq
        end
      end

      def effective_options
        @effective_options = default_options.merge(@options)
      end

      def default_options
        DEFAULT_OPTIONS.merge(@report.options.symbolize_keys)
      end

      def base_template_data(locale)
        {
          'report_title' => @report.report_template.name,
          'chart_data' => JSON.pretty_generate(@report.chart_data),
          'diagnostic_type' => @report.team_diagnostic.diagnostic.name,
          'team_name' => @report.team_diagnostic.name,
          'locale' => locale,
          'organization' => @report.team_diagnostic.organization.name,
          'tenant' => @report.team_diagnostic.organization.tenant.name,
          'team_logo' => @report.team_diagnostic.logo_url,
          'year' => Time.now.year,
          'base_url' => Teamdiagnostic::Application::HOST_AND_PORT
        }
      end
    end
  end
end
