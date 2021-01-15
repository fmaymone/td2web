# frozen_string_literal: true

# Mailer for Team Diagnostic facilitator messages
class TeamDiagnosticMailer < ApplicationMailer
  def deploy_notification_letter(diagnostic)
    @email = [diagnostic.contact_email, diagnostic.alternate_email]
    @subject = diagnostic.deploy_notification_letter_subject
    @content = diagnostic.deploy_notification_letter_body
    mail(to: @email, subject: @subject)
  end

  def cancel_notification_letter(diagnostic)
    @email = [diagnostic.contact_email, diagnostic.alternate_email]
    @subject = diagnostic.cancel_notification_letter_subject
    @content = diagnostic.cancel_notification_letter_body
    mail(to: @email, subject: @subject)
  end
end
