# frozen_string_literal: true

module EntitlementServices
  # Service to claim invitations`
  class InvitationClaim
    attr_reader :invitation, :grants, :errors, :entitlements, :token

    def initialize(tenant:, token:, user: nil)
      @tenant = tenant
      @token = token
      @user = user
      @token.nil? ? set_nil_invitation : set_invitation
      @errors = []
      @grants = []
    end

    def process_limited_invitation
      unless valid_user?
        @errors << 'Invalid user'
        return false
      end

      @invitation.assigned_entitlements.each do |data|
        entitlement = data[:entitlement]
        grant_service = EntitlementServices::Grant.new(
          user: @user,
          entitlement: entitlement,
          quota: data[:quota]
        )
        if grant_service.call
          @grants << grant_service.grant
        else
          grant_service.errors.each do |err|
            @errors << err
          end
        end
      end

      errors?
    end

    def call
      result = limited? ? process_limited_invitation : process_nonlimited_invitation
      yield if block_given? && result
      result
    end

    def redirect_url
      limited? ? @invitation.redirect : @invitation.redirect + "?invitation_id=#{@invitation.id}"
    end

    def valid?(params = nil)
      return @invitation.present? if params.nil?
    end

    def limited?
      valid? ? @invitation.limited? : true
    end

    def set_nil_invitation
      @invitation = nil
      @redirect = nil
      @entitlements = []
      @grants = []
    end

    def set_invitation
      @invitation = Invitation.find_by_tenant_and_token(tenant: @tenant, token: @token)
      if valid?
        @redirect = @invitation.redirect
        @entitlements = @invitation.assigned_entitlements
        @grants = grants_for_invitation
      else
        set_nil_invitation
      end
      @invitation
    end

    def errors?
      @errors.any?
    end

    private

    def process_nonlimited_invitation
      # Only mark as claimed if there is a User to assign
      if @user
        @invitation.claim!
        @invitation.claimed_by = @user
      end
      errors?
    end

    def valid_user?
      @user&.active?
    end

    def grants_for_invitation
      return [] unless @invitation.present?

      @invitation.assigned_entitlements.map do |e|
        entitlement = e[:entitlement]
        quota = e[:quota]
        Grant.new(
          user: @user,
          entitlement: entitlement,
          grantor: invitation.grantor,
          quota: quota
        )
      end
    end
  end
end
