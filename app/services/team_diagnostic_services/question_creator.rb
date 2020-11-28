# frozen_string_literal: true

module TeamDiagnosticServices
  # TeamDiagnostic Question Creator
  # Restricted by Grant
  class QuestionCreator
    attr_reader :params, :user, :team_diagnostic, :team_diagnostic_question, :errors

    def initialize(team_diagnostic:, user:, params: {})
      @team_diagnostic = team_diagnostic
      @user = user
      @policy = TeamDiagnosticQuestionPolicy.new(@user, TeamDiagnosticQuestion)
      @errors = []
      @diagnostic_question = get_diagnostic_question(params)
      @params = sanitize_params(params)
      @team_diagnostic_question = initialize_team_diagnostic_question
    end

    def call
      create_team_diagnostic_question
      valid? ? @team_diagnostic_question : false
    end

    def valid?
      @errors = Validator.new(self, record: @team_diagnostic_question, action: :create).call if @errors.empty?
      @errors.empty?
    end

    def selected_team_diagnostic_open_ended_questions
      @team_diagnostic.questions.open_ended.map { |q| { id: q.id, body: q.body } }
    end

    def available_team_diagnostic_open_ended_questions
      selected =  selected_team_diagnostic_open_ended_questions.map { |q| q[:body] }
      @team_diagnostic.diagnostic.diagnostic_questions.open_ended
                      .map { |q| { id: q.id, body: q.body } }
                      .reject { |q| selected.include?(q[:body]) }
    end

    private

    def get_diagnostic_question(params)
      DiagnosticQuestion.where(id: params[:diagnostic_question_id]).first
    end

    def create_team_diagnostic_question
      @team_diagnostic_question.save if valid?
      valid? ? @team_diagnostic_question : false
    end

    def initialize_team_diagnostic_question
      if @diagnostic_question.present?
        TeamDiagnosticQuestion.from_diagnostic_question(@diagnostic_question, team_diagnostic: @team_diagnostic)
      else
        TeamDiagnosticQuestion.new((@params || {}).merge(
                                     team_diagnostic_id: @team_diagnostic.id,
                                     slug: 'CustomQuestion'
                                   ))
      end
    end

    def sanitize_params(params = {})
      if params.is_a?(ActionController::Parameters)
        allowed_params = @policy.allowed_params
        if params[:team_diagnostic_question].present?
          data = params.require('team_diagnostic_question')
                       .permit(*allowed_params).to_unsafe_h
        end
      else
        data = {
          body: params[:body],
          slug: params[:slug]
        }
      end
      data
    end
  end
end
