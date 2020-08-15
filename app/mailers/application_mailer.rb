# frozen_string_literal: true

# Mailer base class
class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@teamdiagnostic.com' # TODO: use Tenant configuration
  layout 'mailer'
end
