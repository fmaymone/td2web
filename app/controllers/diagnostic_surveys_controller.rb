# frozen_string_literal: true

# DiagnosticSurvey administration controller
class DiagnosticSurveysController < ApplicationController
  before_action :set_diagnostic, only: %i[show edit update destroy]
  before_action :set_service, only: %i[show edit update destroy]

  # GET /diagnostic_surveys/:id
  # Landing/completion page
  def show
    return unless @service.diagnostic_survey.active?

    SystemEvent.log(
      event_source: @service.team_diagnostic,
      incidental: @service.participant,
      description: 'The Diagnostic Survey was visited'
    )
  end

  # GET /diagnostic_surveys/:id/edit
  # Question UI
  def edit
    # Service initialized by before_filter
  end

  # PUT /diagnostic_surveys/:id
  # Submit question response
  def update
    if @service.answer_question
      if @service.completed?
        redirect_to diagnostic_survey_path(id: @service.diagnostic_survey.id)
      else
        redirect_to edit_diagnostic_survey_path(id: @service.diagnostic_survey, team_diagnostic_question_id: @service.next_question)
      end
    else
      redirect_to edit_diagnostic_survey_path(id: @service.diagnostic_survey.id)
    end
  end

  # Unsupported
  def index
    raise ActiveRecord::RecordNotFound
  end

  # Unsupported
  def new
    raise ActiveRecord::RecordNotFound
  end

  # Unsupported
  def destroy
    raise ActiveRecord::RecordNotFound
  end

  private

  # Set @diagnostic_survey and raise 404 if not present or active
  def set_diagnostic
    @diagnostic_survey = DiagnosticSurvey.where(state: %w[active completed], id: params[:id]).first or
      raise ActiveRecord::RecordNotFound
  end

  # Initialize the SurveyService object
  def set_service
    @service = DiagnosticSurveyServices::SurveyService.new(diagnostic_survey: @diagnostic_survey, params:, locale: @current_locale)
    raise ActiveRecord::RecordNotFound unless @service.authorized?

    @service
  end
end
