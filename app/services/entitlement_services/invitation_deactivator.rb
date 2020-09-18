# frozen_string_literal: true

module EntitlementServices
  # Service to deactivate invitations
  class InvitationDeactivator
    attr_reader :invitation, :errors

    def initialize(invitation)
      @invitation = invitation
      @errors = []
    end

    def call
      case @invitation
      when ->(i) { !i.active? }
        @errors << "Can't deactivate an inactive Invitation"
      when ->(i) { i.claimed? }
        @errors << "Can't deactivate a claimed Invitation"
      else
        @invitation.active = false
        @invitation.save
      end
      @errors.any?
    end

    def notice
      @errors.any? ? @errors.join('. ') : 'Invitation was deactivated'.t
    end
  end
end
