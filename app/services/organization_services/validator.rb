# frozen_string_literal: true

module OrganizationServices
  # Helper class for creating Organizations
  class Validator
    # Validates OrganizationServices which respond to: '.user' and '.organization' and optionally '.grantor'
    # Initialize with an OrganizationService and an optional action (Symbol)
    def initialize(service, action: :create)
      @service = service
      @action = action
      @user = service.user
      @grantor = @service.respond_to?(:grantor) ? @service.grantor : @user
      @errors = nil
    end

    def call
      validate
      @errors
    end

    private

    def validate
      @errors = []
      validate_access
      validate_record
    end

    def validate_access
      policy = OrganizationPolicy.new(@grantor, @service.organization)
      access_granted = policy.send(policy_method)
      @errors << 'You do not have permission to create an Organization' unless access_granted
    end

    def validate_record
      @errors += @service.organization.errors.full_messages unless @service.organization.valid?
    end

    def policy_method
      case @action
      when :create, :new
        :new?
      when :edit, :update
        :update?
      when :destroy, :delete
        :destroy
      end
    end
  end
end
