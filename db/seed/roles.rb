# frozen_string_literal: true

# Seed Roles
module Seeds
  # Role seed data
  class Roles
    attr_reader :success, :errors

    def initialize(message: nil)
      @message = message || 'Load Default Roles...'
      @errors = []
      @success = false
    end

    def call
      Role.load_seed_data
    end

    private

    def log(message)
      puts message
      Rails.logger.info message
    end
  end
end
