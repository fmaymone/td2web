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
      success = true
      log('*** Creating seed Entitlements')

      begin
        log('=== Facilitator registration')
        entitlement = Entitlement.new(
          active: true,
          account: false,
          role: Role.facilitator,
          slug: 'register-facilitator',
          reference: 'Users::Registrations#',
          description: 'Account registration as a Facilitator',
          quota: 1
        )
        @errors << entitlement.errors.full_messages unless entitlement.save
      rescue StandardError => e
        puts e
      end

      success
    end

    private

    def log(message)
      puts message
      Rails.logger.info message
    end
  end
end
