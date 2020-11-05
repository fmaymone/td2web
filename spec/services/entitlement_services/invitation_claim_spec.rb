# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntitlementServices::InvitationClaim do
  include_context 'invitations'

  let(:nonlimited_invitation) { registration_invitation }
  let(:limited_invitation) { facilitator_feature_invitation }

  describe 'initialization params' do
    it 'requires a tenant' do
      expect do
        EntitlementServices::InvitationClaim.new(
          token: nonlimited_invitation.token,
          user: nil
        )
      end.to raise_error(StandardError)
    end
    it 'requires a token' do
      expect do
        EntitlementServices::InvitationClaim.new(
          tenant: nonlimited_invitation.tenant,
          user: nil
        )
      end.to raise_error(StandardError)
    end
  end

  describe 'with an account-limited invitation' do
    describe 'initialized without a user' do
      let(:service) do
        EntitlementServices::InvitationClaim.new(
          tenant: limited_invitation.tenant,
          token: limited_invitation.token,
          user: nil
        )
      end
      it 'should not raise an error' do
        service
      end
    end
    describe 'initialized with a user' do
      let(:service) do
        EntitlementServices::InvitationClaim.new(
          tenant: limited_invitation.tenant,
          token: limited_invitation.token,
          user: facilitator
        )
      end
      it 'it should create grants when called' do
        facilitator
        count = Grant.count
        facilitator_grant_count = facilitator.grants.count
        service.call
        facilitator.reload
        expect(service.errors).to be_empty
        expect(Grant.count).to eq(count + 2)
        expect(facilitator.grants.count).to eq(facilitator_grant_count + 2)
      end
    end
  end

  describe 'With a non-account-limited invitation' do
    describe 'initialized without a user' do
      let(:service) do
        EntitlementServices::InvitationClaim.new(
          tenant: nonlimited_invitation.tenant,
          token: nonlimited_invitation.token,
          user: nil
        )
      end
      it 'should be initialized' do
        service
      end
      it 'will not claim the invitation when called' do
        service.call
        nonlimited_invitation.reload
        refute(nonlimited_invitation.claimed?)
      end
    end
    describe 'initialized with a user' do
      let(:service) do
        EntitlementServices::InvitationClaim.new(
          tenant: nonlimited_invitation.tenant,
          token: nonlimited_invitation.token,
          user: staff
        )
      end
      it 'should be initialized' do
        service
      end
      it 'should claim the invitation when called' do
        service.call
        nonlimited_invitation.reload
        assert(nonlimited_invitation.claimed?)
      end
    end
  end
end
