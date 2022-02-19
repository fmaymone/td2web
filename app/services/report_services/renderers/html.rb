# frozen_string_literal: true

module ReportServices
  module Renderers
    # HTML/Liquid report renderer
    class Html < Base
      ID = :html
      TITLE = 'Full Report HTML'
      VERSION = 1
      CONTENT_TYPE = 'text/html'
      LAYOUT_ASSETS_KEYWORD = '[[ASSET_TAGS_HERE]]'
      LAYOUT_ASSET_PACKS = ['report'].freeze

      attr_reader :output

      def call
        super
        build
      end

      # Output report artifacts
      # * HTML file
      # * Chart images in PNG format
      #
      def build
        locales.each do |locale|
          build_for_locale(locale)
        end
      end

      def build_for_locale(locale)
        filename = "#{report.team_diagnostic.name}-#{title}---#{locale}---#{Time.now.strftime('%Y%m%d%H%M')}.html"
        html_data = StringIO.new(generate(locale))
        @report.report_files.attach(io: html_data, filename:, content_type: CONTENT_TYPE)
        html_data.rewind
      end

      def format
        ID
      end

      def title
        TITLE
      end

      def generate(locale)
        layout = render_page(layout_page(locale), 0, locale)
        rendered_pages = []
        content_pages(locale).each_with_index { |page, index| rendered_pages << render_page(page, index + 1, locale) }
        content = rendered_pages.join(' ')
        layout
          .sub(LAYOUT_ASSETS_KEYWORD, layout_asset_tags(locale))
          .sub(LAYOUT_CONTENT_KEYWORD, content)
      end

      def template_data(locale)
        timestamp = Time.now
        base_template_data(locale).merge(
          {
            'page_size' => (locale.to_s == 'en' ? 'letter' : 'A4'),
            'date' => timestamp,
            'year' => timestamp.year
          }
        )
      end

      private

      def optional_style
        @options.fetch(:style, '')
      end

      def layout_asset_tags(locale)
        tags = []
        LAYOUT_ASSET_PACKS.each do |packname|
          css_path = Webpacker.manifest.lookup("#{packname}.css")
          if css_path
            tags << <<~END_OF_TAGS
              <link rel="stylesheet" href="#{host_prefix}#{css_path}"></link>
            END_OF_TAGS
          end

          tags << <<~END_OF_TAGS
            <style>
              @page {
                size: #{locale.to_s == 'en' ? 'letter' : 'A4'}  landscape;
              }
              #{optional_style}
            </style>
          END_OF_TAGS

          tags << @options[:css] if @options[:css]

          tags << <<~END_OF_TAGS
            <script type="text/javascript">
              window.report_locale = "#{locale}"
              window.report_chart_data = #{JSON.pretty_generate @report.chart_data}
            </script>
          END_OF_TAGS

          js_path = Webpacker.manifest.lookup("#{packname}.js")
          next unless js_path

          tags << <<~END_OF_TAGS
            <script src="#{host_prefix}#{js_path}"></script>
          END_OF_TAGS
        end
        tags.join(' ')
      end

      def page_template_data(page, data, page_index)
        data.merge(
          { 'page' => page_index, 'slug' => page.slug }
        )
      end

      def render_page(page, page_index, locale)
        apply_liquid_config
        template = Liquid::Template.parse(page.markup)
        template.render(page_template_data(page, template_data(locale), page_index))
      end

      def apply_liquid_config
        Liquid::Template.error_mode = (Rails.env.test? || Rails.env.development?) ? :strict : :lax
      end
    end
  end
end
