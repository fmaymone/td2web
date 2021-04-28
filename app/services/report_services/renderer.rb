# frozen_string_literal: true

module ReportServices
  # Report Renderer Service
  class Renderer
    class Error < StandardError; end

    # Renderers in order of dependency
    RENDERERS = [
      Renderers::Html,
      Renderers::Pdf
    ].freeze

    def initialize(report, formats: :all, locale: nil)
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
      end
    end

    private

    def all_formats
      RENDERERS.map { |r| r::ID }
    end

    def get_formats(formats)
      case formats
      when :all
        all_formats
      else
        [all_formats.find { |format| format.to_s == formats.to_s }].compact
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
