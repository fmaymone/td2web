# frozen_string_literal: true

# Entitlement Invitation Mailer
class InvitationMailer < ApplicationMailer
  def entitlement_invitation(invitation)
    puts "Sending an entitlement_invitation to #{invitation.email}"

    @invitation = invitation
    @email = @invitation.email
    @content = @invitation.email_body
    @subject = @invitation.email_subject

    mail(to: @email, subject: @subject)
  rescue StandardError => e
    Rails.logger.error("Error sending entitlement invitation: #{e.message}")
    # You can also log the backtrace for more detailed information
    Rails.logger.error(e.backtrace.join("\n"))
    # You might want to notify yourself or the development team
    # about the error, for example, using an error tracking service.
    # Example: Bugsnag.notify(e)
  end
end
