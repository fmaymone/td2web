# frozen_string_literal: true

module Seeds
  # Organization seed data
  class Organizations
    attr_reader :success
    attr_reader :errors

    def initialize(message: nil)
      @message = message || 'Create default TCI organization...'
      @errors = []
      @success = false
    end

    def call
      Organization.transaction do
        print @message if @message
        organization = Organization.new(
          name: 'Team Coaching International',
          slug: 'default',
          description: 'Site Administrator',
          domain: 'localhost',
          active: true
        )
        @success = organization.save
        @errors = organization.errors.to_a unless @success
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
