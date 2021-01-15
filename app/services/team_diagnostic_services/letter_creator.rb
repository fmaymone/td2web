# frozen_string_literal: true
## frozen_string_literal: true

# module TeamDiagnosticServices
## TeamDiagnostic Letter Creator
## Restricted by Grant
# class LetterCreator
# attr_reader :params, :user, :team_diagnostic, :team_diagnostic_letter, :errors

# def initialize(team_diagnostic:, user:, params: {})
# @team_diagnostic = team_diagnostic
# @user = user
# @policy = TeamDiagnosticLetterPolicy.new(@user, TeamDiagnosticLetter)
# @errors = []
# @params = sanitize_params(params)
# @team_diagnostic_letter = initialize_team_diagnostic_letter
# end

# def call
# create_team_diagnostic_letter
# valid? ? @team_diagnostic_letter : false
# end

# def valid?
# @errors = Validator.new(self, record: @team_diagnostic_letter, action: :create).call if @errors.empty?
# @errors.empty?
# end

# private

# def create_team_diagnostic_letter
# @team_diagnostic_letter.save if valid?
# valid? ? @team_diagnostic_letter : false
# end

# def initialize_team_diagnostic_letter
# TeamDiagnosticLetter.new((@params || {}).merge(team_diagnostic_id: @team_diagnostic.id))
# end

# def sanitize_params(params = {})
# if params.is_a?(ActionController::Parameters)
# allowed_params = @policy.allowed_params
# if params[:team_diagnostic_letter].present?
# data = params.require('team_diagnostic_letter')
# .permit(*allowed_params).to_unsafe_h
# end
# else
# data = {
# body: params[:body],
# subject: params[:subject],
# locale: params[:locale]
# }
# end
# data
# end
# end
# end
