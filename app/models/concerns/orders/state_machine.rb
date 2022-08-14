# frozen_string_literal: true

module Orders
  # Orders State Machine
  module StateMachine
    extend ActiveSupport::Concern

    SUBMISSION_MESSAGE = 'Your order was submitted'

    included do
      include AASM

      aasm column: :state do
        state :pending
        state :submitted
        state :paid
        state :completed
        state :cancelled

        event :submit do
          transitions from: :pending, to: :submitted
          after do
            save
            SystemEvent.log(
              event_source: orderable,
              incidental: user,
              description: SUBMISSION_MESSAGE,
              severity: :info
            )
            submit_invoice
          end
        end

        event :make_payment do
          transition from: :submitted, to: :paid
          guard do
            # invoices.where(state: Invoice::ACTIVE_STATES).any?
          end
        end
      end

      def after_submission
        self.submitted_at = Time.current
        save
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
