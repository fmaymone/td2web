# frozen_string_literal: true

module Users
  # User model class extension for Role features
  module Roles
    extend ActiveSupport::Concern

    included do
      belongs_to :role

      delegate :admin?, :staff?, :translator?, :facilitator?, :member?, to: :role
    end

    class_methods do
      def admins
        includes(:role).where(roles: { slug: Role::ADMIN_ROLE })
      end

      def staff
        includes(:role).where(roles: { slug: Role::STAFF_ROLE })
      end

      def translators
        includes(:role).where(roles: { slug: Role::STAFF_ROLE })
      end

      def facilitators
        includes(:role).where(roles: { slug: Role::FACILITATOR_ROLE })
      end

      def members
        includes(:role).where(roles: { slug: Role::MEMBER_ROLE })
      end
    end
  end
end
