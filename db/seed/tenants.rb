# frozen_string_literal: true

module Seeds
  # Tenant seed data
  class Tenants
    attr_reader :success
    attr_reader :errors

    def initialize(message: nil)
      @message = message || 'Create default TCI tenant...'
      @errors = []
      @success = false
    end

    def call
      Tenant.transaction do
        print @message if @message
        tenant = Tenant.new(
          name: 'Team Coaching International',
          slug: 'default',
          description: 'Site Administrator',
          domain: 'localhost',
          active: true
        )
        @success = tenant.save
        @errors = tenant.errors.to_a unless @success
        @success
      end
    end

    private

    def log(message)
      puts message
      Rails.logger.info message
    end
  end
end
