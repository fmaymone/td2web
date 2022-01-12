# frozen_string_literal: true

module ReportServices
  # Report Renderer Service
  class Renderer
    class Error < StandardError; end

    # Renderers in order of dependency
    RENDERERS = [
      Renderers::Html,
      Renderers::Pdf,
      Renderers::Png
    ].freeze

    # Renderers run by default
    STANDARD_RENDERERS = [
      Renderers::Html,
      Renderers::Pdf,
      Renderers::Png
    ].freeze

    def initialize(report, formats: :standard, locale: nil)
      @report = report
      @team_diagnostic = report.team_diagnostic
      @locale = locale

      raise(Error, 'Team Diagnostic must be completed to render a report') unless @team_diagnostic.allow_reporting?

      @formats = get_formats(formats)
      @renderers = get_renderers(@formats)
    end

    def call
      @renderers.each do |renderer|
        renderer.new(report: @report, locale: @locale).call
      rescue StandardError => e
        log_rendering_error(e, renderer)
      end
      complete_report
    end

    def all_formats
      RENDERERS.map { |r| r::ID }
    end

    def standard_formats
      STANDARD_RENDERERS.map { |r| r::ID }
    end

    private

    def complete_report
      @report.reload
      if @report.rendering? && @report.report_files.present?
        @report.complete
        @report.save
        @report.reload
        @report.completed?
      else
        false
      end
    end

    def log_rendering_error(error, renderer)
      renderer_name = renderer::ID
      error_description = "Problem generating #{renderer_name}"
      SystemEvent.log(event_source: @report.team_diagnostic, description: error_description, severity: :error, debug: error.message)
    end

    def get_formats(formats)
      case formats
      when :all
        all_formats
      when :standard
        standard_formats
      when Array
        all_formats.select { |format| formats.include?(format.to_sym) }
      else
        []
      end
    end

    def get_renderers(formats)
      formats.map { |format| find_renderer(format) }
    end

    def find_renderer(format)
      f = format.to_sym
      renderer = RENDERERS.find { |r| r::ID.to_sym == f }
      raise Error, "Report renderer for #{format} not found" unless renderer

      renderer
    end
  end
end
