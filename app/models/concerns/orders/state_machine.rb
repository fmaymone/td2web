# frozen_string_literal: true

module Orders
  # Orders State Machine
  module StateMachine
    extend ActiveSupport::Concern

    SUBMISSION_MESSAGE = 'Your order was submitted'
    ACTIVE_STATES = %i[pending finalized submitted paid].freeze
    INCOMPLETE_STATES = %i[pending finalized submitted].freeze

    included do
      include AASM

      scope :active, -> { where(state: ACTIVE_STATES).order(updated_at: :desc) }
      scope :incomplete, -> { where(state: INCOMPLETE_STATES).order(updated_at: :desc) }

      aasm column: :state do
        state :pending
        state :finalized
        state :submitted
        state :paid
        state :completed
        state :cancelled

        event :finalize do
          transitions from: :pending, to: :finalized
        end

        event :reset_to_pending do
          transitions from: :finalized, to: :pending
          after do
            reset_totals!
            order_discounts.destroy_all
            order_discounts.reload
            true
          end
        end

        event :submit do
          transitions from: :finalized, to: :submitted
          after do
            apply_permanent_coupons!
            calculate_total!
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
          transitions from: :submitted, to: :paid do
            guard do
              # invoices.where(state: Invoice::ACTIVE_STATES).any?
            end
          end
        end

        event :cancel do
          transitions from: INCOMPLETE_STATES, to: :cancelled
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
