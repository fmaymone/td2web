# frozen_string_literal: true

module TeamDiagnostics
  # StateMachine features for TeamDiagnostic model
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM

      attr_accessor :force_completion

      aasm column: :state do
        state :setup, initial: true
        state :deployed
        state :completed
        state :reported
        state :cancelled

        event :deploy do
          before { perform_deployment }
          after { activate_participants }
          transitions from: %i[setup cancelled], to: :deployed do
            guard { deployment_succeeded && !deployment_issues? }
          end
        end

        event :complete do
          after { after_completion }
          transitions from: :deployed, to: :completed
        end

        event :report do
          transitions from: :completed, to: :reported do
            guard { allow_completion? }
          end
        end

        event :cancel do
          before { cancel_deployment }
          transitions from: %i[setup deployed], to: :cancelled
        end
      end

      def trigger_event(event_name:, user: false)
        event = event_name.to_sym
        if permitted_state_events.include?(event)
          aasm.fire(event, user)
          save
        else
          false
        end
      end

      def permitted_state_events
        aasm.events(permitted: true).map(&:name)
      end

      def permitted_states
        aasm.states(permitted: true).map(&:name)
      end

      def guard_report
        return true if allow_completion?

        SystemEvent.log(
          event_source: self,
          incidental: nil,
          description: 'The Diagnostic could not be marked as complete due to low participation',
          severity: :error
        )
        false
      end

      def allow_completion?
        deployed? && (force_completion || diagnostic_surveys.completed.count >= diagnostic.minimum_participants)
      end

      def after_completion
        participants.active.each(&:cancel!)
        log_completion
      end

      def log_completion
        SystemEvent.log(
          event_source: self,
          incidental: nil,
          description: 'The Diagnostic was completed',
          severity: :warn
        )
      end
    end
  end
end
