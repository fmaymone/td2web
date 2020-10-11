# frozen_string_literal: true

module EntitlementServices
  # Verify User entitlement
  class Authorizer
    class AuthorizationError < StandardError; end

    attr_reader :user, :reference

    def initialize(tenant:, user: nil, params: nil, reference: nil)
      @tenant = tenant
      @user = user
      @params = params
      @references = reference ? Array(reference) : resolve_references(@params)
    end

    def call(slug = nil)
      return false unless @references.present?

      @user.present? ? authorize_user(slug) : authorized_invitations(slug).present?
    end

    def invitation_role
      authorized_invitations.map { |ai| ai.assigned_entitlements.map { |e| e[:entitlement] } }
                            .flatten.compact.map(&:role).uniq
                            .max
    end

    private

    def authorize_user(slug = nil)
      skope = @user.grants.valid.where(reference: @references)
      skope = skope.includes(:entitlement).where(entitlement: { slug: slug }) if slug
      skope.any?
    end

    def authorized_invitations(slug = nil)
      token = @params[:token]
      return false unless token.present?

      skope = @tenant.invitations.unclaimed.where(token: token)
      if slug
        skope.to_a.select { |i| i.assigned_entitlements.any? { |e| e[:entitlement].reference == slug } }
      else
        skope.to_a.select { |i| i.assigned_entitlements.any? { |e| @references.include?(e[:entitlement].reference) } }
      end
    end

    def resolve_references(params)
      AppContext.for_params(params)
    end
  end
end
