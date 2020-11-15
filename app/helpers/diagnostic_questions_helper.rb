# frozen_string_literal: true

# View Helpers
module DiagnosticQuestionsHelper
  def diagnostic_question_categories_for_select(question)
    options = DiagnosticQuestion::DEFAULT_CATEGORIES.map { |c| [c, c] }
    options_for_select(options, question.category)
  end

  def diagnostic_question_types_for_select(question)
    options = DiagnosticQuestion::DEFAULT_TYPES.sort.map { |t| [t, t] }
    options_for_select(options, question.question_type)
  end

  def diagnostic_question_factors_for_select(question)
    options = DiagnosticQuestion::DEFAULT_FACTORS.sort.map { |f| [f, f] }
    options_for_select(options, question.factor)
  end
end
