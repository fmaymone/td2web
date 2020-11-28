# frozen_string_literal: true

module ParticipantServices
  # Validator class for ParticipantServices
  class Validator
    def initialize(service, action: :create)
      @service = service
      @action = action
      @user = service.user
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
      policy = ParticipantPolicy.new(@user, @service.participant || Participant)
      access_granted = policy.send(policy_method)
      @errors << 'You do not have permission' unless access_granted
    end

    def validate_record
      @errors += @service.participant.errors.full_messages unless @service.participant.valid?
    end

    def policy_method
      case @action
      when :create, :new
        :new?
      when :edit, :update
        :update?
      when :destroy, :delete
        :destroy?
      when :disqualify
        :disqualify?
      when :restore
        :restore?
      end
    end
  end
end
