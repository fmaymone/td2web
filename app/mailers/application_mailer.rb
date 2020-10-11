# frozen_string_literal: true

# Mailer base class
class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('EMAIL_REPLY_TO', 'noreply@teamdiagnostic.com')
  layout 'mailer'
end
