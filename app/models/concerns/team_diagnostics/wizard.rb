# frozen_string_literal: true

module TeamDiagnostics
  # Wizard functionality
  module Wizard
    extend ActiveSupport::Concern

    WIZARD_STEPS = %w[setup questions participants letters deploy report].freeze
    SETUP_STEP = 1
    QUESTIONS_STEP = 2
    LETTERS_STEP = 4
    PARTICIPANTS_STEP = 3
    DEPLOY_STEP = 5
    REPORT_STEP = 6

    included do
      def total_wizard_steps
        wizard_steps.size
      end

      def increment_wizard!
        increment!(:wizard) unless wizard_complete?
        true
      end

      def wizard_complete?
        wizard == total_wizard_steps
      end

      def wizard_step_name(step = nil)
        wizard_steps[[0, (step || wizard) - 1].max]
      end

      def next_wizard_step
        wizard_complete? ? wizard : wizard + 1
      end

      def wizard_steps
        TeamDiagnostic::WIZARD_STEPS
      end

      def wizard_step_attention_items(step)
        items = []
        case step
        when TeamDiagnostic::SETUP_STEP
          items << 'Information is missing or invalid'.t unless valid?
        when TeamDiagnostic::QUESTIONS_STEP
          items << 'Please create Open Ended Question translations'.t unless sufficient_open_ended_question_translations?
        when TeamDiagnostic::LETTERS_STEP
          items << 'Please create letter translations'.t unless sufficient_letter_translations?
        when TeamDiagnostic::PARTICIPANTS_STEP
          items << 'Please invite more participants'.t unless sufficient_participants?
          items << 'There are new participants pending activation'.t if participants_pending_activation?
        when TeamDiagnostic::DEPLOY_STEP
          items << pending_actions
        when TeamDiagnostic::REPORT_STEP
          items << pending_actions
          items << 'The Diagnostic is not completed'.t unless completed? || reported?
        end
        items.flatten
      end
    end
  end
end
