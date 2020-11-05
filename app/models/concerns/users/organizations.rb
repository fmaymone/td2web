# frozen_string_literal: true

module Users
  # User Organization Logic
  module Organizations
    extend ActiveSupport::Concern

    included do
      has_many :organization_memberships, class_name: 'OrganizationUser'
      has_many :organizations, through: :organization_memberships

      def organization_role(organization)
        organization_memberships
          .where(organization_id: organization.id)
          .first&.role
      end

      def organization_membership_date(organization)
        organization_memberships
          .where(organization_id: organization.id)
          .first&.created_at
      end
    end
  end
end
