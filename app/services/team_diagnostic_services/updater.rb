# frozen_string_literal: true

module TeamDiagnosticServices
  # TeamDiagnostic Updater
  class Updater
    REFERENCE = 'TeamDiagnostics#update'
    WHITELISTED_PARAMS = [:id].freeze

    attr_reader :params, :user, :team_diagnostic, :errors, :step, :updated

    def initialize(user:, id:, params: {})
      Rails.logger.info(`TeamDiagnosticServices::Updater initializing #{params}`)
      @errors = []
      @user = user
      @id = id
      @policy = TeamDiagnosticPolicy.new(@user, TeamDiagnostic)
      @policy_scope = TeamDiagnosticPolicy::Scope.new(@user, TeamDiagnostic).resolve
      @params = sanitize_params(params)
      @team_diagnostic = initialize_team_diagnostic
      @step = get_step(params[:step])
      @updated = false
      Rails.logger.info(`TeamDiagnosticServices::Updater initialized`)
    end

    def call
      update_team_diagnostic
      if valid?
        after_save
        @team_diagnostic
      else
        false
      end
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

    def step_needs_attention?(step = nil)
      @team_diagnostic.wizard_step_attention_items(step || @step).any?
    end

    def step_attention_items
      @team_diagnostic.wizard_step_attention_items(@step)
    end

    def next_step_accessible?
      return false if @step >= @team_diagnostic.total_wizard_steps
      return false if @step >= current_step + 1

      true
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

    def deployment_issues
      errors = valid? ? [] : @errors
      errors + @team_diagnostic.deployment_issues
    end

    def current_step
      @team_diagnostic.wizard
    end

    def letters_for_form_typed(letter_type)
      letters = team_diagnostic.team_diagnostic_letters.typed(letter_type).to_a
      locales = letters.pluck(:locale)
      unless locales.include?(@team_diagnostic.locale)
        letters << TeamDiagnosticLetter.default_letter(
          type: letter_type,
          locale: @team_diagnostic.locale,
          team_diagnostic: @team_diagnostic
        )
      end
      letters.sort_by(&:locale)
    end

    def update_notice
      @updated ? 'Team Diagnostic updated'.t : nil
    end

    private

    def after_save
      SystemEvent.log(event_source: @team_diagnostic, description: 'Updated') if @updated
    end

    def letter_data_present?
      @params.present? && @params.fetch('team_diagnostic_letters_attributes', []).first.present?
    end

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
      @team_diagnostic.team_diagnostic_letters << @team_diagnostic.missing_letters unless letter_data_present?
      @team_diagnostic
    end

    def update_team_diagnostic
      TeamDiagnostic.transaction do
        @team_diagnostic.assign_attributes(@params || {})
        @updated = @team_diagnostic.has_changes_to_save?
        if valid? && @team_diagnostic.save
          @team_diagnostic.increment_wizard! if @step == @team_diagnostic.wizard
          true
        else
          @updated = false
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
