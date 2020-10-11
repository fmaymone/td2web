# frozen_string_literal: true

# Entitlement Invitation Mailer
class InvitationMailer < ApplicationMailer
  def entitlement_invitation(invitation)
    @invitation = invitation
    @email = @invitation.email
    @content = @invitation.email_body
    @subject = @invitation.email_subject
    mail(to: @email, subject: @subject)
  end
end
