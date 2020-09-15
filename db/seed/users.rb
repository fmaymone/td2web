# frozen_string_literal: true

# Seed Users
module Seeds
  # User seed data
  class Users
    attr_reader :success, :errors

    def initialize(message: nil)
      @message = message || '*** Create default users...'
      @errors = []
      @success = false
    end

    def call
      log(@message) if @message

      username = 'administrator'
      password = Array.new(12) { rand(32..125).chr }.join
      log('*** Creating "administrator" Admin account...')

      if User.where(username: username).exists?
        log("=== Account with username: '#{username}' already exists.")
        @success = true
        return @success
      end

      user0 = User.new(
        tenant: Tenant.default_tenant,
        role: Role.admin,
        username: username,
        email: 'admin@example.com',
        locale: 'en',
        timezone: 'Pacific Time (US & Canada)',
        password: password,
        password_confirmation: password,
        user_profile_attributes: {
          first_name: 'Admin',
          last_name: 'Admin',
          country: 'USA'
        }
      )
      @success = user0.save
      if @success
        log("=== #{username} password is: #{password}")
        user0.confirmed_at = DateTime.now
        user0.save!
      else
        @errors = user0.errors.to_a unless @success
      end
      @success
    end

    private

    def log(message)
      puts message
      Rails.logger.warn message
    end
  end
end
