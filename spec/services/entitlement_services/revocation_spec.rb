# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntitlementServices::Revocation do
  include_context 'entitlements'
  include_context 'users'

  let(:facilitator_grant) do
    service = EntitlementServices::Grant.new(user: facilitator, grantor: staff, entitlement: entitlement_for_facilitators)
    service.call
  end
  let(:deactivated_grant) do
    service = EntitlementServices::Grant.new(user: facilitator, grantor: staff, entitlement: entitlement_for_facilitators)
    grant = service.call
    grant.active = false
    grant.save
    grant
  end

  before(:each) { admin }

  describe 'Staff revoking an existing grant' do
    it 'should should deactivate the grant' do
      assert(facilitator_grant.active?)
      service = EntitlementServices::Revocation.new(grant: facilitator_grant, grantor: staff)
      service.call
      facilitator_grant.reload
      refute(facilitator_grant.active?)
    end
  end

  describe 'Staff re-enabling a revoked grant' do
    it 'should re-activate the grant' do
      refute(deactivated_grant.active?)
      service = EntitlementServices::Revocation.new(grant: facilitator_grant, grantor: staff)
      service.restore
      facilitator_grant.reload
      assert(facilitator_grant.active?)
    end
  end
end
