# frozen_string_literal: true

module DiagnosticSurveyServices
  # DiagnosticSurvey Question repository
  class QuestionService
    attr_reader :diagnostic_survey, :params, :locale

    def initialize(diagnostic_survey:, locale: nil)
      @diagnostic_survey = diagnostic_survey
      @locale = locale || diagnostic_survey.locale
    end

    def all_questions
      diagnostic_survey.questions
                       .where(locale: locale || @locale, active: true)
                       .order('question_type DESC, matrix ASC')
    end

    def rating_questions
      all_questions.rating
    end

    def rating_questions_completed?
      rating_questions.count == all_responses.rating.count
    end

    def open_ended_questions
      all_questions.open_ended
    end

    def open_ended_questions_completed?
      open_ended_questions.count == all_responses.open_ended.count
    end

    def all_questions_completed?
      all_questions.count == all_responses.count
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
                       .where(team_diagnostic_question_id: question.id, locale: @locale)
                       .first&.response
    end

    def previous_question(reference_question = nil)
      cq_id = (reference_question || current_question)&.id
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

    def next_question(reference_question = nil)
      cq_id = (reference_question || current_question)&.id
      all_question_ids = all_questions.pluck(:id)
      case cq_id
      when nil
        nil
      when all_question_ids.last
        nil
      else
        all_questions.where(id: all_question_ids[all_question_ids.index(cq_id) + 1]).first
      end
    end

    def all_responses
      diagnostic_survey.diagnostic_responses.includes(:team_diagnostic_question)
    end

    def last_response
      all_responses
        .where(locale: @locale)
        .order('team_diagnostic_questions.question_type ASC, team_diagnostic_questions.matrix DESC')
        .first
    end

    def last_answered_question
      last_response&.team_diagnostic_question
    end

    def answer_question(question:, response:, locale: nil)
      old_response = diagnostic_survey.diagnostic_responses.where(team_diagnostic_question: question, locale: locale || @locale).first
      new_response = old_response || diagnostic_survey.diagnostic_responses
                                                      .new(team_diagnostic_question: question,
                                                           locale: locale || @locale)
      new_response.response = response
      new_response.save
      new_response
    end
  end
end
