# frozen_string_literal: true

module UserProfiles
  module NotificationPreferences
    extend ActiveSupport::Concern

    TRUTHY = [true, 'true', 't', '1'].freeze
    ADMIN_NOTIFY = 'admin_notify'

    included do
      def notification_admin_errors
        self.notification_preferences ||= {}
        TRUTHY.include?(
          notification_preferences.fetch(ADMIN_NOTIFY, false).to_s
        )
      end

      def notification_admin_errors?
        TRUTHY.include?(notification_admin_errors)
      end

      def notification_admin_errors=(value)
        self.notification_preferences ||= {}
        self.notification_preferences[ADMIN_NOTIFY] = TRUTHY.include?(value)
      end
    end
  end
end
