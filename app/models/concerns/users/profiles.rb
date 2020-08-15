# frozen_string_literal: true

module Users
  # User Profile Extensions
  module Profiles
    extend ActiveSupport::Concern

    included do
      has_one :user_profile, dependent: :destroy
      accepts_nested_attributes_for :user_profile, update_only: true

      def name
        return email unless user_profile.present?

        [user_profile.prefix, user_profile.first_name, user_profile.middle_name, user_profile.last_name, user_profile.suffix].compact.join(' ').gsub(/ +/, ' ').strip
      end

      def pronoun
        user_profile&.pronoun
      end

      def country_name
        user_profile&.country_name || ''
      end

      def required_consent_pending?
        user_profile ? user_profile.required_consent_pending? : true
      end

      def required_consents_pending
        user_profile ? user_profile.required_consents_pending : []
      end

      def consent_granted?(key)
        user_profile ? user_profile.consent_granted?(key) : true
      end

      def consent_revoked?(key)
        user_profile ? user_profile.consent_revoked?(key) : true
      end

      def update_consents(params)
        user_profile ? user_profile.update_consents(params) : false
        save
      end

      def revoke_consent(key)
        user_profile ? user_profile.revoke_consent(key) : false
        save
      end
    end
  end
end
