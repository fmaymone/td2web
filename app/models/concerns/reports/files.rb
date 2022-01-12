# frozen_string_literal: true

module Reports
  # Support for files associated with the Report
  module Files
    extend ActiveSupport::Concern

    included do
      has_many_attached :report_files

      def rendered_files(format: nil)
        service = ReportServices::Renderers::Base.new(report: self)
        files = service.files
        format_sym = format ? format.to_sym : nil
        case format_sym
        when :html
          files.select { |f| f[:format] == ReportServices::Renderers::Html::CONTENT_TYPE }
        when :pdf
          files.select { |f| f[:format] == ReportServices::Renderers::Pdf::CONTENT_TYPE }
        when :png
          files.select { |f| f[:format] == ReportServices::Renderers::Png::CONTENT_TYPE }
        else
          files
        end
      end
    end
  end
end
