# frozen_string_literal: true

module ParticipantServices
  # TeamDiagnostic Participant creator
  class Creator
    attr_reader :participant, :params, :team_diagnostic, :errors, :user

    def initialize(user:, team_diagnostic:, params: {})
      @errors = []
      @user = user
      @policy = ParticipantPolicy.new(@user, Participant)
      @params = sanitized_params(params)
      @team_diagnostic = team_diagnostic or raise 'A TeamDiagnostic must be provided to create a Participant'
      @participant = initialize_participant
    end

    def call
      create_participant
      valid? ? @participant : false
    end

    def valid?
      @errors = Validator.new(self, action: :create).call if @errors.empty?
      @errors.empty?
    end

    private

    def create_participant
      @participant.save! if valid?
      @participant
    end

    def initialize_participant
      participant = Participant.new(@params)
      participant.team_diagnostic_id = @team_diagnostic.id
      participant.locale ||= @team_diagnostic.locale
      participant.timezone ||= @team_diagnostic.timezone
      participant
    end

    def sanitized_params(params)
      if params.is_a?(ActionController::Parameters)
        allowed_params = @policy.allowed_params
        data = params.require('participant').permit(*allowed_params).to_unsafe_h if params[:participant].present?
      else
        data = params
      end
      data
    end
  end
end
