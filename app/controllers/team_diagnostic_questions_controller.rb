# frozen_string_literal: true

# TeamDiagnosticQuestion Management Controller
class TeamDiagnosticQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team_diagnostic
  after_action :verify_authorized

  # def index
  # authorize  TeamDiagnosticQuestion
  # @team_diagnostic_questions = @team_diagnostic.questions
  # @current_page = 'List'.t
  # end

  def create
    authorize TeamDiagnosticQuestion
    @question_service = TeamDiagnosticServices::QuestionCreator.new(user: @current_user, team_diagnostic: @team_diagnostic, params:)
    respond_to do |format|
      @created = @question_service.call
      @team_diagnostic_question = @question_service.team_diagnostic_question
      @team_diagnostic.reload
      if @created
        format.js
        format.json { render :show, status: :created, location: @team_diagnostic_question }
      else
        format.js { render :create, status: :unprocessable_entity }
        format.json { render json: @question_service.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    set_team_diagnostic_question
    authorize @team_diagnostic_question
    @team_diagnostic_question.destroy
    SystemEvent.log(event_source: @team_diagnostic, description: 'A question was deleted')
    @question_service = TeamDiagnosticServices::QuestionCreator.new(user: @current_user, team_diagnostic: @team_diagnostic, params:)
    respond_to do |format|
      format.js
    end
  end

  private

  def record_scope
    @team_diagnostic ? policy_scope(@team_diagnostic.questions) : policy_scope(TeamDiagnosticQuestion)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_team_diagnostic_question
    @team_diagnostic_question = record_scope.find(params[:id])
  end

  def set_team_diagnostic
    if params[:team_diagnostic_id]
      policy = TeamDiagnosticPolicy::Scope.new(current_user, TeamDiagnostic)
      @team_diagnostic = policy.resolve.where(id: params[:team_diagnostic_id]).first
    else
      @team_diagnostic_question ? @team_diagnostic_question.team_diagnostic : (raise ActiveRecord::RecordNotFound)
    end
  end
end
