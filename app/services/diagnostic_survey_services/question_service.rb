# frozen_string_literal: true

module DiagnosticSurveyServices
  # DiagnosticSurvey Question repository
  class QuestionService
    attr_reader :diagnostic_survey, :params

    def initialize(diagnostic_survey:, params: {})
      @diagnostic_survey = diagnostic_survey
      @params = params
    end

    def all_questions(locale = nil)
      diagnostic_survey.questions
                       .where(locale: locale || diagnostic_survey.locale, active: true)
                       .order('question_type DESC, matrix ASC')
    end

    # The question that the participant should be answering right now
    # returns nil if all questions have been answered
    def current_question
      all_responded_question_ids = diagnostic_survey.diagnostic_responses.pluck(:team_diagnostic_question_id)
      all_questions.where
                   .not(id: all_responded_question_ids)
                   .order(matrix: :asc)
                   .first
    end

    def question_response(question)
      diagnostic_survey.diagnostic_responses
                       .where(team_diagnostic_question_id: question.id)
                       .first&.response
    end

    def previous_question
      cq_id = current_question&.id
      all_question_ids = all_questions.pluck(:id)
      case cq_id
      when nil
        all_questions.last
      when all_question_ids.first
        nil
      else
        all_questions.where(id: all_question_ids[all_question_ids.index(cq_id) - 1]).first
      end
    end

    # def next_question
    # cq_id = current_question&.id
    # all_question_ids = all_questions.pluck(:id)
    # case cq_id
    # when nil
    # nil
    # when all_question_ids.last
    # nil
    # else
    # all_questions.where(id: all_question_ids[all_question_ids.index(cq_id) + 1]).first
    # end
    # end

    def last_response
      diagnostic_survey.diagnostic_responses.includes(:team_diagnostic_question)
                       .order('team_diagnostic_questions.question_type ASC, team_diagnostic_questions.matrix DESC')
                       .first
    end

    def last_answered_question
      last_response&.team_diagnostic_question
    end

    def answer_question(question:, response:)
      response = diagnostic_survey.diagnostic_reponses
                                  .new(team_diagnostic_question: question,
                                       response: response)
      response.save
      response
    end
  end
end
