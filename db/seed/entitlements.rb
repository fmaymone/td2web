# frozen_string_literal: true

# Seed Entitlements
module Seeds
  # Entitlement seed data
  class Entitlements
    def initialize(message: nil)
      @message = message || 'Load Default Entitlements...'
      @errors = []
      @success = false
    end

    def call
      Entitlement.load_seed_data
    end

    private

    def log(message)
      puts message
      Rails.logger.info message
    end
  end
end
