# frozen_string_literal: true

module TeamDiagnostics
  # Wizard functionality
  module Wizard
    extend ActiveSupport::Concern

    WIZARD_STEPS = %w[setup customize questions participants deploy].freeze
    SETUP_STEP = 1
    CUSTOMIZE_STEP = 2
    QUESTIONS_STEP = 3
    PARTICIPANTS_STEP = 4
    DEPLOY_STEP = 5

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
    end
  end
end
