# frozen_string_literal: true

module ReportServices
  # Report chart data generator
  class DataGenerator
    class Error < StandardError; end

    GENERATORS = [
      DataGenerators::TeamMatrixPosition,
      DataGenerators::PolarChart,
      DataGenerators::ProductivityStrengths,
      DataGenerators::PositivityStrengths,
      DataGenerators::HighestLowestProductivityRatings,
      DataGenerators::HighestLowestPositivityRatings,
      DataGenerators::LeastAgreement,
      DataGenerators::MostAgreement
    ].freeze

    attr_reader :team_diagnostic, :locale

    def initialize(report)
      @report = report
      @team_diagnostic = report.team_diagnostic
      raise(Error, 'Team Diagnostic must be completed to generate chart data') unless @team_diagnostic.allow_reporting?

      @locale = @team_diagnostic.locale
    end

    def call
      return @report if @report.started_at.present?

      SystemEvent.log(event_source: @report.team_diagnostic, incidental: @report, description: 'Started generating a report', severity: :info)
      @report.started_at = Time.now
      @report.save!
      data = report_data
      @report.reload
      return @report unless @report.running?

      @report.chart_data = data
      @report.save!
      @report.render!
      @report
    end

    private

    def report_data
      any_errors = false
      data = GENERATORS.each_with_object({}) do |klass, memo|
        generator = klass.new(@team_diagnostic)
        memo['_index'] ||= []
        begin
          memo[generator.id] = generator.call
          memo['_index'] << generator.id
          SystemEvent.log(event_source: @report, incidental: @report.team_diagnostic, description: "Generated chart data for #{generator.class}", severity: :debug)
        rescue StandardError => e
          any_errors = true
          SystemEvent.log(event_source: @report, incidental: @report.team_diagnostic, description: "Error generating chart data for #{generator.class}", debug: "#{e.message}\n---\n#{e.backtrace.join("\n")}", severity: :error)
        end
      end
      SystemEvent.log(
        event_source: @report.team_diagnostic,
        incidental: @report,
        description: 'Error generating Report chart data',
        severity: :error
      ) if any_errors
      data
    end
  end
end
