# frozen_string_literal: true

module TeamDiagnosticServices
  # Helper class for Validating TeamDiagnostic services
  class Validator
    # Validates TeamDiagnosticServices which respond to: '.user' and '.team_diagnostic'
    # Initialize with an TeamDiagnosticService and an optional action (Symbol)
    def initialize(service, record: nil, action: :create)
      @service = service
      @action = action
      @user = service.user
      @errors = nil
      @record = record || @service.team_diagnostic
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
      policy = TeamDiagnosticPolicy.new(@user, @service.team_diagnostic)
      access_granted = policy.send(policy_method)
      @errors << 'You do not have permission' unless access_granted
    end

    def validate_record
      @errors += @record.errors.full_messages unless @record.valid?
    end

    def policy_method
      case @action
      when :new
        :new?
      when :create
        :create?
      when :edit, :update
        :update?
      when :destroy, :delete
        :destroy
      end
    end
  end
end
