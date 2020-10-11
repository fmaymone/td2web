# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntitlementServices::Grant do
  include_context 'entitlements'
  include_context 'users'

  before(:each) do
    admin
    # staff
    # facilitator
  end

  describe 'Admin granting an entitlement to a staff member' do
    it 'should create a grant' do
      count = Grant.count
      service = EntitlementServices::Grant.new(user: staff, grantor: admin, entitlement: entitlement_for_staff)
      result = service.call
      assert(result && result.valid?)
      staff.reload
      expect(staff.grants.last).to eq(result)
      expect(Grant.count).to eq(count + 1)
    end
    describe 'which is of too high privilege' do
      it 'should fail to create a grant' do
        count = Grant.count
        service = EntitlementServices::Grant.new(user: staff, grantor: admin, entitlement: entitlement_for_admins)
        result = service.call
        refute(result)
        facilitator.reload
        expect(facilitator.grants.count).to eq(0)
        expect(Grant.count).to eq(count)
      end
    end
  end

  describe 'Staff granting an entitlement' do
    describe 'with an equal or lower entitlement role' do
      it 'should create a grant' do
        count = Grant.count
        service = EntitlementServices::Grant.new(user: facilitator, grantor: staff, entitlement: entitlement_for_facilitators)
        result = service.call
        assert(result && result.valid?)
        facilitator.reload
        expect(facilitator.grants.last).to eq(result)
        expect(Grant.count).to eq(count + 1)
      end
    end
    describe 'with a higher role entitlement' do
      it 'should fail to create a grant' do
        count = Grant.count
        service = EntitlementServices::Grant.new(user: facilitator, grantor: staff, entitlement: entitlement_for_admins)
        result = service.call
        refute(result)
        facilitator.reload
        expect(facilitator.grants.count).to eq(0)
        expect(Grant.count).to eq(count)
      end
    end
  end
end
