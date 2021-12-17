# frozen_string_literal: true

module Reports
  # State machine for Report model
  module StateMachine
    extend ActiveSupport::Concern

    REPORT_EVENT_LOG_DESCRIPTIONS = {
      start: 'Starting report generation',
      render: 'Creating report files',
      complete: 'Report generation is complete',
      reject: 'Report cancelled'
    }.freeze

    included do
      scope :in_progress, -> { where(state: %i[running rendering]) }

      include AASM

      aasm column: :state do
        state :pending, initial: true
        state :running
        state :rendering
        state :completed
        state :rejected

        event :start do
          transitions from: [:pending], to: :running
          after do
            log_report_event(:start)
            reset_token
            save!
            service = ReportServices::DataGenerator.new(self)
            # Datagenerator SHOULD trigger the render event if successful
            service.delay.call
          end
        end

        event :render do
          transitions from: [:running], to: :rendering
          after do
            log_report_event(:render)
            service = ReportServices::Renderer.new(self, formats: :standard)
            # Renderer SHOULD trigger the complete event if successful
            service.delay.call
            true
          end
        end

        event :complete do
          transitions from: [:rendering], to: :completed
          after do
            log_report_event(:complete)
            true
          end
        end

        event :reject do
          transitions from: %i[pending running rendering completed], to: :rejected
          after do
            log_report_event(:reject)
            reset_token
            save
          end
        end
      end

      def log_report_event(event_name)
        description = REPORT_EVENT_LOG_DESCRIPTIONS.fetch(event_name.to_sym, nil)
        return false unless description

        SystemEvent.log(
          event_source: self,
          incidental: nil,
          description: 'Diagnostic report is being generated',
          severity: :warn
        )
      end
    end
  end
end
