# frozen_string_literal: true

module EntitlementServices
  # Verify User entitlement
  class Authorizer
    class AuthorizationError < StandardError; end

    attr_reader :user, :reference

    def initialize(tenant: nil, user: nil, params: nil, reference: nil)
      raise 'Need either a tenant or a user parameter to initialize EntitlementServices::Authorizer' unless tenant || user

      @user = user
      @tenant = tenant || user&.tenant
      @params = params
      @references = reference ? Array(reference) : resolve_references(@params)
    end

    def call(slug = nil)
      # Admins are not restricted by Entitlements
      return true if @user&.admin?
      # Automatic fail if the functional reference cannot be resolved
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
      skope = skope.includes(:entitlement).where(entitlements: { slug: slug }) if slug
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
