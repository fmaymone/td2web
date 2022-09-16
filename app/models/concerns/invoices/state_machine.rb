# frozen_string_literal: true

module Invoices
  # Invoice State Machine
  module StateMachine
    extend ActiveSupport::Concern

    ACTIVE_STATES = %i[pending accepted paid].freeze
    PAID_STATES = %i[accepted paid].freeze

    included do
      include AASM

      aasm column: :state do
        state :pending
        state :accepted
        state :paid
        state :cancelled
        state :refunded

        event :accept do
          transitions from: :pending, to: :accepted
          after :after_acceptance
        end

        event :pay do
          transitions from: :accepted, to: :paid
          after :after_payment
        end

        event :cancel do
          transitions from: %i[pending acccepted]
        end

        event :refund do
          transitions from: :paid, to: :refunded
        end
      end

      def after_acceptance
        return unless state == 'accepted'

        self.accepted_at = Time.current
        save
      end

      def after_payment
        return unless state == 'paid'

        self.paid_at = Time.current
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
