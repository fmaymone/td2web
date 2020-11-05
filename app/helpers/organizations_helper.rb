# frozen_string_literal: true

# Organization View Helper
module OrganizationsHelper
  def organization_role_badge(organization)
    org_role = @current_user.organization_role(organization) || 'none'
    badge_class = "badge badge-light"
    content_tag(:span, org_role.capitalize.t, class: badge_class)
  end
end
