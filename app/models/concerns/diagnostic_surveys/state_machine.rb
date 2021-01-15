# frozen_string_literal: true

module DiagnosticSurveys
  # StateMachine features for TeamDiagnostic model
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM

      aasm column: :state do
        state :pending, initial: true
        state :active
        state :completed
        state :cancelled

        event :activate do
          transitions from: :pending, to: :active,
                      guard: :no_other_active, after: :send_invitation_message
        end

        event :cancel do
          transitions from: %i[pending active], to: :cancelled, after: :send_cancellation_message
        end

        event :complete do
          transitions from: :active, to: :completed
        end
      end

      # def trigger_event(event_name:, user: false)
      # event = event_name.to_sym
      # if permitted_state_events.include?(event)
      # aasm.fire(event, user)
      # save
      # else
      # false
      # end
      # end

      # def permitted_state_events
      # aasm.events(permitted: true).map(&:name)
      # end

      # def permitted_states
      # aasm.states(permitted: true).map(&:name)
      # end

      def no_other_active
        participant.diagnostic_surveys.active.where.not(id: id).none?
      end
    end
  end
end
