# frozen_string_literal: true

module Reports
  # State machine for Report model
  module StateMachine
    extend ActiveSupport::Concern

    included do
      scope :in_progress, -> { where(state: %i[running rendering]) }

      include AASM

      aasm column: :state do
        state :pending, initial: true
        state :running
        state :rendering
        state :completed
        state :rejected

        event :start do
          transitions from: [:pending], to: :running
          after do
            reset_token
            save!
            service = ReportServices::DataGenerator.new(self)
            service.delay.call
          end
        end

        event :render do
          transitions from: [:running], to: :rendering
          after do
            service = ReportServices::Renderer.new(self, formats: :standard)
            service.delay.call
            true
          end
        end

        event :complete do
          transitions from: [:rendering], to: :completed
        end

        event :reject do
          transitions from: %i[pending running rendering completed], to: :rejected
          after do
            reset_token
            save
          end
        end
      end
    end
  end
end
