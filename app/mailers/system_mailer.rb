# frozen_string_literal: true

# System Mailer class
class SystemMailer < ApplicationMailer
  helper :system_events

  def error_digest(events:, notify_users:)
    @subject = 'TeamDiagnostic Recent Errors'
    @events = events
    @emails = notify_users.map(&:email)
    mail(to: @emails, subject: @subject)
  end
end
