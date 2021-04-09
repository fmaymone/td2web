# frozen_string_literal: true

module DiagnosticSurveyServices
  # Service and helpers for presentation and completion of a DiagnosticSurvey
  class SurveyService
    STEPS = %i[intro rating open_ended conclusion].freeze
    attr_reader :diagnostic_survey, :team_diagnostic, :participant, :team_diagnostic_question, :step, :locale, :params, :response

    def initialize(diagnostic_survey:, params: {}, locale: nil)
      @params = params
      @diagnostic_survey = find_diagnostic_survey(diagnostic_survey)
      @team_diagnostic = @diagnostic_survey.team_diagnostic
      @locale = locale || @params.fetch(:locale, @diagnostic_survey.locale)
      @question_service = DiagnosticSurveyServices::QuestionService.new(diagnostic_survey: @diagnostic_survey)
      @team_diagnostic_question = find_current_question
      @step = determine_step
      @response = @params.fetch(:response, nil)
      @errors = []
      @participant = @diagnostic_survey.participant
    end

    def participant_name
      @participant.full_name
    end

    def team_name
      @diagnostic_survey.team_diagnostic.name
    end

    def diagnostic_name
      @diagnostic_survey.team_diagnostic.diagnostic.name
    end

    # Return if the survey is active
    def authorized?
      active? || completed?
    end

    def active?
      @diagnostic_survey.active?
    end

    def started?
      @diagnostic_survey.diagnostic_responses.any?
    end

    def completed?
      @question_service.all_questions_completed? || @diagnostic_survey.completed? || @diagnostic_survey.cancelled?
    end

    def current_question
      @team_diagnostic_question
    end

    def current_question_response
      @question_service.question_response(current_question)
    end

    def current_question_answered?
      current_question_response.present?
    end

    def current_question_number
      current_question.rating? ? current_question.matrix : nil
    end

    def next_question
      @question_service.next_question(current_question)
    end

    def previous_question
      @question_service.previous_question(current_question)
    end

    def answer_question
      response_count = @diagnostic_survey.diagnostic_responses.count
      result = @question_service.answer_question(question: current_question, response: @response, locale: @locale)
      if result
        @diagnostic_survey.last_activity_at = result.created_at
        @diagnostic_survey.save
        if completed?
          # If all questions have been answered mark as completed and log event
          complete!
        elsif response_count.zero?
          # If this is the first response, log the start of the survey
          SystemEvent.log(
            event_source: @diagnostic_survey.participant,
            incidental: @diagnostic_survey,
            description: 'The Diagnostic Survey was started',
            severity: :warn
          )
        end
        result
      else
        false
      end
    end

    def confirm_completion
      if @diagnostic_survey.active? && @question_service.all_questions_completed?
        @diagnostic_survey.complete!
        true
      else
        false
      end
    end

    def show_next_button?
      nq = next_question
      nq.present? && @question_service.question_response(current_question).present?
    end

    def show_previous_button?
      previous_question.present?
    end

    def complete!
      return unless @diagnostic_survey.active? && @question_service.all_questions_completed?

      @diagnostic_survey.complete!
      @diagnostic_survey.reload

      SystemEvent.log(
        event_source: @diagnostic_survey.participant,
        incidental: @diagnostic_survey,
        description: 'The Diagnostic Survey was completed',
        severity: :warn
      )
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
