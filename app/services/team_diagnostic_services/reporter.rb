# frozen_string_literal: true

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
      reset_current_report
      perform_report(force: true, options:)
    end

    # Latest report
    def current_report
      @current_report ||= begin
        skope = @team_diagnostic.reports.order(started_at: :desc)
        skope.completed.first || skope.rendering.first || skope.running.first || skope.pending.first ||
          init_report
      end
    end

    def reset_current_report
      @current_report = nil
    end

    def cancel
      reject_report_states = Report::VALID_REPORT_STATES - [:pending]
      @team_diagnostic.reports.where(state: reject_report_states).each do |report|
        report.reject
        report.save
      end
      reset_current_report
      @team_diagnostic.reports.reload
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
      @team_diagnostic.reports.where(state: %i[running rendering]).any?
    end

    def may_reset?
      status != :pending
    end

    def all_pages(locale = 'en')
      current_report.available_pages(locale)
    end

    def available_pages(locale = 'en')
      a = all_pages(locale).to_a
      @available_pages = current_report.page_order.map { |index| a[index - 1] }.compact
      @available_pages = (a - @available_pages) + @available_pages

      @available_pages
    end

    def custom_pagination?
      all_pages.map(&:index) != selected_pages.map(&:index)
    end

    def selected_pages(locale = 'en')
      current_report.selected_pages(locale)
    end

    def page_selected?(page)
      page_index = (page.respond_to?(:index) ? page.index : page).to_i
      selected_pages.map(&:index).include?(page_index)
    end

    private

    def init_report(options: {})
      report_template = @team_diagnostic.diagnostic.report_template
      @team_diagnostic.reports.create!(
        description: "#{@team_diagnostic.name} Report",
        report_template:,
        options:
      )
    end

    # Trigger the generation of a new report
    #
    # may force cancelling any running reports
    # may supply options including page_order
    # options: {page_order: :default || [2,5,6,10] }
    #
    def perform_report(force: false, options: {})
      # TODO: check for entitlements
      #
      @team_diagnostic.reports.stalled.map(&:reject)
      reset_current_report
      @team_diagnostic.reports.reload

      running_reports = @team_diagnostic.reports.where(state: %i[running rendering])
      return running_reports.order(updated_at: :desc).first if !force && running_reports.any?

      running_reports.all.map(&:reject)
      report = init_report(options:)
      report.start
      report
    end
  end
end
