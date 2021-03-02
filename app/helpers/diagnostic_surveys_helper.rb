# frozen_string_literal: true

# View helpers for DiagnosticSurvey UI
module DiagnosticSurveysHelper
  def question_body(question)
    if question.open_ended?
      question.body
    else
      question.body.t
    end
  end

  def current_question_number_badge_class(service)
    service.current_question_answered? ? 'success' : 'light'
  end

  def current_question_number(service)
    qn = service.current_question_number
    content_tag(:span, qn, class: "badge badge-pill badge-#{current_question_number_badge_class(service)}") if qn.present?
  end

  def question_response_button_class(service, value)
    service.current_question_response == value.to_s ? 'success' : 'primary'
  end

  def current_question_body(service)
    current_question = service.current_question
    if service.locale == current_question.locale
      service.current_question.body
    else
      reference_body = current_question.body
      translated_body = (reference_body.t || {})
      if translated_body == {}
        reference_body
      else
        translated_body
      end
    end
  end
end
