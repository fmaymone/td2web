# frozen_string_literal: true

# Mailer for Team Diagnostic notification messages
class DiagnosticSurveyMailer < ApplicationMailer
  def cover_letter(survey)
    @email = survey.email
    @subject = survey.cover_letter_subject
    @content = survey.cover_letter_body
    mail(to: @email, subject: @subject)
  end

  def reminder_letter(survey)
    @email = survey.email
    @subject = survey.reminder_letter_subject
    @content = survey.reminder_letter_body
    mail(to: @email, subject: @subject)
  end

  def cancellation_letter(survey)
    @email = survey.email
    @subject = survey.cancellation_letter_subject
    @content = survey.cancellation_letter_body
    mail(to: @email, subject: @subject)
  end
end
