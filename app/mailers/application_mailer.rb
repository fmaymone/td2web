# frozen_string_literal: true

# Mailer base class
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com' # TODO: use Organization configuration
  layout 'mailer'
end
