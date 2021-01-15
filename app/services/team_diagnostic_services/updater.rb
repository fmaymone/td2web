# frozen_string_literal: true

module TeamDiagnosticServices
  # TeamDiagnostic Updater
  class Updater
    REFERENCE = 'TeamDiagnostics#update'
    WHITELISTED_PARAMS = [:id].freeze

    attr_reader :params, :user, :team_diagnostic, :errors, :step

    def initialize(user:, id:, params: {})
      @errors = []
      @user = user
      @id = id
      @policy = TeamDiagnosticPolicy.new(@user, TeamDiagnostic)
      @policy_scope = TeamDiagnosticPolicy::Scope.new(@user, TeamDiagnostic).resolve
      @team_diagnostic = initialize_team_diagnostic
      @params = sanitize_params(params)
      @step = get_step(params[:step])
    end

    def call
      update_team_diagnostic
      valid? ? @team_diagnostic : false
    end

    def valid?
      @errors = Validator.new(self, action: :update).call
      @errors.empty?
    end

    def step_name
      @team_diagnostic.wizard_step_name(@step)
    end

    def step_accessible?(step)
      step <= current_step
    end

    def next_step_accessible?
      return false if @step >= @team_diagnostic.total_wizard_steps
      return false if @step >= current_step + 1

      true
    end

    # def wizard_complete?
    # @team_diagnostic.wizard_complete?
    # end

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

    def deployment_issues
      errors = valid? ? [] : @errors
      errors << 'Please add participants'.t unless @team_diagnostic.sufficient_participants?
      errors || []
    end

    def current_step
      @team_diagnostic.wizard
    end

    private

    def step_completed_or_present?
      step <= current_step && guard_deploy_step
    end

    def guard_deploy_step
      @team_diagnostic.wizard != TeamDiagnostics::Wizard::PARTICIPANTS_STEP
    end

    def show_wizard?
      @team_diagnostic.wizard_complete?
    end

    def get_step(step_number = nil)
      current_step = @team_diagnostic.wizard || 1
      [(step_number || current_step).to_i, current_step].min
    end

    def initialize_team_diagnostic
      @team_diagnostic = @policy_scope.where(id: @id).first or raise ActiveRecord::RecordNotFound
    end

    def update_team_diagnostic
      TeamDiagnostic.transaction do
        @team_diagnostic.assign_attributes(@params || {})
        if valid? && @team_diagnostic.update(@params || {})
          @team_diagnostic.increment_wizard! if @step == @team_diagnostic.wizard
          true
        else
          false
        end
      end
    rescue StandardError
      false
    end

    def sanitize_params(params = {})
      if params.is_a?(ActionController::Parameters)
        allowed_params = @policy.allowed_params + WHITELISTED_PARAMS
        data = params.require('team_diagnostic').permit(*allowed_params).to_unsafe_h if params[:team_diagnostic].present?
      else
        data = params
      end
      data
    end
  end
end