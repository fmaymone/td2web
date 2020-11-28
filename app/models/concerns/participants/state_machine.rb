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
          transitions from: :active, to: :completed, if: :survey_completed?
        end

        event :disqualify do
          transitions from: %i[approved active], to: :disqualified
        end

        event :requalify do
          transitions from: :disqualified, to: :approved
        end
      end

      def permitted_state_events
        aasm.events(permitted: true).map(&:name)
      end

      def permitted_states
        aasm.states(permitted: true).map(&:name)
      end

      def activation_permitted?
        valid?
      end

      def after_activation
        # TODO
        # initialize diagnostic_survey
        # send invitation email
        # Log the activation
      end

      # Delegates to diagnostic_survey.completed?
      def survey_completed?
        # TODO
        # diagnostic_survey.completed?
        false
      end

      def disqualify_survey
        # TODO
        # diagnostic_survey.disqualify!
      end
    end
  end
end
