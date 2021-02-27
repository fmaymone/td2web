# frozen_string_literal: true

module DiagnosticSurveyServices
  # Service and helpers for presentation and completion of a DiagnosticSurvey
  class SurveyService
    STEPS = %i[intro rating open_ended conclusion].freeze
    attr_reader :diagnostic_survey, :team_diagnostic_question, :step, :locale, :params, :response

    def initialize(diagnostic_survey:, params: {})
      @params = params
      @diagnostic_survey = find_diagnostic_survey(diagnostic_survey)
      @locale = @params.fetch(:locale, @diagnostic_survey.locale)
      @question_service = DiagnosticSurveyServices::QuestionService.new(diagnostic_survey: @diagnostic_survey)
      @team_diagnostic_question = find_current_question
      @step = determine_step
      @response = @params.fetch(:response, nil)
    end

    def authorized?(email: nil)
      compare_email = email || @params[:email]
      return false unless compare_email.present?

      @diagnostic_survey.active? &&
        @diagnostic_survey.participant&.email == compare_email
    end

    def started?
      @diagnostic_survey.diagnostic_responses.any?
    end

    def current_question
      @team_diagnostic_question
    end

    def current_question_response
      @question_service.question_response(current_question)
    end

    def next_question
      @question_service.next_question(current_question)
    end

    def previous_question
      @question_service.previous_question(current_question)
    end

    def answer_question
      @question_service.answer_question(question: current_question, response: @response, locale: @locale)
    end

    def confirm_completion
      if @diagnostic_survey.active? && @question_service.all_questions_completed?
        @diagnostic_survey.complete!
        true
      else
        false
      end
    end

    private

    def find_current_question
      question_id = @params.fetch(:team_diagnostic_question_id, nil)
      if question_id.present?
        @diagnostic_survey.questions.find(question_id)
      else
        @question_service.current_question
      end
    end

    def find_diagnostic_survey(diagnostic_survey)
      case diagnostic_survey
      when DiagnosticSurvey
        @diagnostic_survey = diagnostic_survey
      when String
        @diagnostic_survey = DiagnosticSurvey.active.find(diagnostic_survey)
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    def determine_step
      return :intro if @question_service.all_responses.none?
      return :conclusion if @question_service.all_questions_completed?
      return :open_ended if @question_service.rating_questions_completed? &&
                            !@question_service.open_ended_questions_completed?

      :rating
    end
  end
end
