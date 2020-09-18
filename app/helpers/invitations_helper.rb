# frozen_string_literal: true

# Invitation view helpers
module InvitationsHelper
  def invitation_claimed_badge(invitation)
    classes = "badge badge-#{invitation.claimed_at.present? ? 'success' : 'secondary'}"
    content_tag(:span, class: classes) do
      invitation.claimed? ? 'Claimed'.t : 'Unclaimed'.t
    end
  end

  def invitation_status(invitation)
    classes = "badge badge-#{invitation.active? ? 'success' : 'warning'}"
    content_tag(:span, class: classes) do
      invitation.active? ? 'Active'.t : 'Revoked'.t
    end
  end

  def invitation_entitlement_list(invitation)
    content_tag(:ol) do
      invitation.assigned_entitlements.each do |entitlement|
        concat content_tag(:li, invitation_entitlement(entitlement))
      end
    end
  end

  def invitation_entitlement(entitlement)
    description = entitlement[:entitlement]&.description
    quota = content_tag(:span, entitlement[:quota], class: 'badge badge-primary')
    content_tag(:span, "#{quota} #{description}".html_safe)
  end

  def options_for_invitation_redirect(invitation)
    urls = [
      ['Dashboard'.t, root_url],
      ['Register Account', new_user_registration_url]
    ]
    options_for_select(urls, invitation.redirect)
  end
end
