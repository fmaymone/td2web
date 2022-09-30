# frozen_string_literal: true

module TeamDiagnosticServices
  # TeamDiagnostic Creator
  # Restricted by Grant
  class Creator
    REFERENCE = 'TeamDiagnostics#create'
    ENTITLEMENT_BASE = 'create-diagnostic'
    DEFAULT_COVER_LETTER = 'template-teamdiagnostic-cover-letter'
    DEFAULT_REMINDER_LETTER = 'template-teamdiagnostic-reminder-letter'
    DEFAULT_CANCELLATION_LETTER = 'template-teamdiagnostic-cancellation-letter'

    attr_reader :params, :user, :team_diagnostic, :errors, :step

    def initialize(user:, params: {})
      @user = user
      @policy = TeamDiagnosticPolicy.new(@user, TeamDiagnostic)
      @params = sanitize_params(params)
      @errors = []
      @team_diagnostic = initialize_team_diagnostic
      @step = 1
    end

    def call
      # !!! Entitlement usage disabled for the time being
      #
      # service = EntitlementServices::GrantUsage.new(user: @user, reference: REFERENCE)
      # unless service.call { create_team_diagnostic }
      # @errors ||= []
      # @errors += service.errors
      # end

      create_team_diagnostic

      if valid?
        after_save
        @team_diagnostic
      else
        false
      end
    end

    def valid?
      @errors = Validator.new(self, action: :create).call if @errors.empty?
      @errors.empty?
    end

    def entitled_diagnostics
      @policy.entitled_diagnostics
    end

    def entitled_diagnostics_options
      entitled_diagnostics.map { |d| [d.name, d.id] }
    end

    def organization_options
      @user.organizations.order(name: :asc).map { |o| [o.name, o.id] }
    end

    def functional_area_options
      TeamDiagnostic::FUNCTIONAL_AREAS.map { |a| [a.t, a] }
    end

    def team_type_options
      TeamDiagnostic::TEAM_TYPES.map { |a| [a.t, a] }
    end

    private

    def after_save
      SystemEvent.log(event_source: @team_diagnostic, description: 'Created')
    end

    def initialize_team_diagnostic
      team_diagnostic = TeamDiagnostic.new(@params)
      assign_defaults(team_diagnostic)
    end

    def assign_defaults(team_diagnostic)
      team_diagnostic.wizard = 1
      team_diagnostic.user = @user
      team_diagnostic.diagnostic ||= entitled_diagnostics.first
      team_diagnostic.contact_email ||= @user.email
      team_diagnostic.contact_phone ||= @user.user_profile&.phone_number
      team_diagnostic.locale ||= @user.locale
      team_diagnostic.timezone ||= @user.timezone
      team_diagnostic.team_diagnostic_letters = team_diagnostic.missing_letters
      team_diagnostic
    end

    def create_team_diagnostic
      if valid?
        TeamDiagnostic.transaction do
          @team_diagnostic.save!
          @team_diagnostic.increment_wizard!
        end
        true
      else
        false
      end
    rescue StandardError
      false
    end

    def sanitize_params(params = {})
      if params.is_a?(ActionController::Parameters)
        allowed_params = @policy.allowed_params
        data = params.require('team_diagnostic').permit(*allowed_params).to_unsafe_h if params[:team_diagnostic].present?
      else
        data = params
      end
      data
    end
  end
end
