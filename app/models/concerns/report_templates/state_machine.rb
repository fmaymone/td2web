# frozen_string_literal: true

module ReportTemplates
  # State machine for ReportTemplate model
  module StateMachine
    extend ActiveSupport::Concern

    included do
      include AASM

      aasm column: :state do
        state :draft, initial: true
        state :published

        event :publish do
          transitions from: [:draft], to: :published
        end

        event :unpublish do
          transitions from: [:published], to: :draft
        end
      end
    end
  end
end
