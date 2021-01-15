# frozen_string_literal: true

module TeamDiagnostics
  # StateMachine features for TeamDiagnostic model
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM

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
          transitions from: :deployed, to: :completed
        end

        event :report do
          transitions from: :completed, to: :reported
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
    end
  end
end
