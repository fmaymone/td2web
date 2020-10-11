# frozen_string_literal: true

module UserProfiles
  # User Consent
  module Consent
    extend ActiveSupport::Concern

    ### Constants
    CONSENT_PARAMS = %w[eula cookies_required].freeze
    REQUIRED_CONSENTS = %w[eula cookies_required].freeze

    # Consent Error
    class ConsentUnauthorizedError < StandardError; end

    included do
      serialize :consent

      def required_consents_pending
        self.consent ||= {}
        REQUIRED_CONSENTS.select do |key|
          expired_date = if (revoked_date = consent.fetch("#{key}_revoked_at", nil))
                           revoked_date
                         elsif (granted_date = consent.fetch("#{key}_granted_at", nil))
                           granted_date + 6.months
                         else
                           DateTime.now
                         end
          expired_date <= DateTime.now
        end
      end

      def required_consent_pending?
        required_consents_pending.any?
      end

      def consent_granted?(key)
        self.consent ||= {}
        if [true, 'true', 1, '1'].include? consent.fetch(key.to_s, '0')
          begin
            consent.fetch("#{key}_granted_at", DateTime.now.to_s)
          rescue StandardError
            DateTime.now
          end
        else
          false
        end
      end

      def consent_revoked?(key)
        self.consent ||= {}
        consent.fetch("#{key}_revoked_at", false)
      end

      def grant_consent(key)
        self.consent ||= {}
        consent["#{key}_revoked_at"] = nil
        consent[key.to_s] = '1'
        consent["#{key}_granted_at"] = DateTime.now
      end

      def update_consents(params)
        consent_params = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params
        CONSENT_PARAMS.each do |key|
          if (val = consent_params.fetch(key, false))
            val == '1' ? grant_consent(key) : revoke_consent(key)
          end
        end
        true
      end

      def revoke_consent(key)
        self.consent ||= {}
        consent[key] = '0'
        consent["#{key}_revoked_at"] = DateTime.now
      end
    end
  end
end
