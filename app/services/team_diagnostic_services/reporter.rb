module TeamDiagnosticServices
  # TeamDiagnostic Reporting View Service
  class Reporter
    REFERENCE = 'TeamDiagnostics#report'

    attr_reader :team_diagnostic

    def initialize(team_diagnostic)
      raise 'Must initialize with a TeamDiagnostic' unless team_diagnostic.is_a?(TeamDiagnostic)

      @team_diagnostic = team_diagnostic
    end

    # (re)Generate TeamDiagnostic Report
    def call(options: {})
      cancel
      report = perform_report(force: true, options: options)
      report
    end

    # Latest report
    def current_report
      skope = @team_diagnostic.reports.order(started_at: :desc)
      skope.completed.first || skope.rendering.first || skope.running.first || init_report
    end

    def cancel
      @team_diagnostic.reports.where(state: Report::VALID_REPORT_STATES).each do |report|
        report.reject
        report.save
      end
    end

    def status
      return :stalled if stalled?
      return :running if running?
      return :completed if current_report.completed?

      :pending
    end

    def status_css_class
      {
        stalled: 'danger',
        running: 'warning',
        completed: 'success',
        pending: 'info'
      }.fetch(status, 'dark')
    end

    def stalled?
      skope = @team_diagnostic.reports.order(started_at: :desc)
      return false unless skope.stalled.any?

      skope.completed.any? ? skope.completed.first.completed_at < skope.stalled.first.started_at : true
    end

    def running?
      @team_diagnostic.reports.where(state: [:running, :rendering]).any?
    end

    def may_reset?
      status != :pending
    end

    private

    def init_report(options: {})
      report_template = @team_diagnostic.diagnostic.report_template
      @team_diagnostic.reports.create!(
        description: "#{@team_diagnostic.name} Report",
        report_template: report_template,
        options: options
      )
    end

    # Trigger the generation of a new report
    #
    # may force cancelling any running reports
    # may supply options including page_order
    # options: {page_order: :default || [2,5,6,10] }
    #
    def perform_report(force: false, options: {})
      @team_diagnostic.reports.stalled.each(:reject)
      @team_diagnostic.reports.reload

      running_reports = @team_diagnostic.reports.where(state: %i[running rendering])
      return running_reports.order(updated_at: :desc).first if !force && running_reports.any?

      running_reports.all.map(&:reject)
      report = init_report(options: options)
      report.start
      report
    end

  end
end
