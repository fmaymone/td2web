# frozen_string_literal: true

# Seed Products
module Seeds
  # Product seed data
  class Products
    def initialize(message: nil)
      @message = message || 'Load Default Products...'
      @errors = []
      @success = false
    end

    def call
      Product.load_seed_data
    end

    private

    def log(message)
      puts message
      Rails.logger.info message
    end
  end
end
