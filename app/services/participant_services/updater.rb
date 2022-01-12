# frozen_string_literal: true

module ParticipantServices
  # Participant Updater
  class Updater
    attr_reader :params, :user, :participant, :errors

    def initialize(user:, id:, params: {})
      @errors = []
      @user = user
      @id = id
      @policy = ParticipantPolicy.new(@user, Participant)
      @policy_scope = ParticipantPolicy::Scope.new(@user, Participant).resolve
      @params = sanitize_params(params)
      @participant = initialize_participant
    end

    def call
      update_participant
    end

    def disqualify!
      return unless valid?(:disqualify)

      @participant.transaction do
        handle_near_empty_diagnostic
        @participant.disqualify!
        SystemEvent.log(event_source: @participant.team_diagnostic, incidental: @participant, description: 'A participant was disqualified')
      end
    end

    def restore!
      valid?(:restore) && @participant.requalify! &&
        SystemEvent.log(event_source: @participant.team_diagnostic, incidental: @participant, description: 'A participant was restored')
    end

    def destroy!
      return unless valid?(:destroy)

      @participant.transaction do
        handle_near_empty_diagnostic
        @participant.destroy!
        SystemEvent.log(event_source: @participant.team_diagnostic, incidental: @participant, description: 'A participant was removed')
      end
    end

    def activate!
      begin
        @participant.activate!
      rescue StandardError
        false
      end
      @participant.active?
    end

    def valid?(action = :update)
      return false unless @errors.empty?

      @errors = Validator.new(self, action:).call
      @errors.empty?
    end

    private

    def handle_near_empty_diagnostic
      return unless @participant.team_diagnostic.wizard > 2 && @participant.team_diagnostic.participants.count == 1

      @participant.team_diagnostic.wizard = 3
      @participant.team_diagnostic.save
    end

    def update_participant
      if valid? && @participant.update(@params)
        SystemEvent.log(event_source: @participant.team_diagnostic, incidental: @participant, description: 'A participant was updated')
        @participant
      else
        false
      end
    end

    def sanitize_params(params)
      if params.is_a?(ActionController::Parameters)
        allowed_params = @policy.allowed_params
        data = params.require('participant').permit(*allowed_params).to_unsafe_h if params[:participant].present?
      else
        data = params
      end
      data
    end

    def initialize_participant
      Participant.find(@id)
    end
  end
end
