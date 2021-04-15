# frozen_string_literal: true

# Participant Concern
module Participants
  # Participant state machine logic
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM

      aasm column: :state do
        state :approved, initial: true
        state :active
        state :completed
        state :disqualified

        event :activate do
          transitions from: :approved, to: :active, after: :after_activation, if: :activation_permitted?
        end

        event :complete do
          transitions from: :active, to: :completed
        end

        event :disqualify do
          transitions from: %i[approved active], to: :disqualified, after: :after_disqualification
        end

        event :requalify do
          transitions from: :disqualified, to: :approved
        end

        event :cancel do
          transitions from: :active, to: :approved, after: :after_cancel
        end
      end

      # def permitted_state_events
      # aasm.events(permitted: true).map(&:name)
      # end

      # def permitted_states
      # aasm.states(permitted: true).map(&:name)
      # end

      def activation_permitted?
        valid? && team_diagnostic&.deployed?
      end

      def after_activation
        return false unless approved? || active?

        create_active_survey
      end

      def after_disqualification
        cancel_surveys
      end

      def after_cancel
        cancel_surveys
      end
    end
  end
end
