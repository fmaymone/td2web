# frozen_string_literal: true

# Seed Entitlements
module Seeds
  # Diagnostic seed data
  class Diagnostics
    def initialize(message: nil)
      @message = message || 'Load Default Diagnostics...'
      @errors = []
      @success = false
    end

    def call
      Diagnostic.load_seed_data
    end

    private

    def log(message)
      puts message
      Rails.logger.info message
    end
  end
end
