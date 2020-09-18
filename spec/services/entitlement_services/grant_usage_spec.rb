# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntitlementServices::GrantUsage do
  include_context 'entitlements'
  include_context 'users'

  let(:user) { facilitator }
  let(:grant) { EntitlementServices::Grant.new(user: user, entitlement: entitlement_for_facilitators, quota: 2).call }

  before(:each) do
    admin
  end

  describe 'with an effective Grant' do
    it 'should create a usage of the grant' do
      count = GrantUsage.count
      expect(grant.usages.count).to eq(0)
      service = EntitlementServices::GrantUsage.new(user: user, reference: grant.reference)
      assert(service.call)
      grant.reload
      expect(GrantUsage.count).to eq(count + 1)
      expect(grant.usages.count).to eq(1)
      assert(grant.effective?)
      assert(service.call)
      grant.reload
      expect(grant.usages.count).to eq(2)
      refute(grant.effective?)
    end
    describe 'given a block' do
      it 'should create the usage if the block returns true' do
        count = GrantUsage.count
        expect(grant.usages.count).to eq(0)
        service = EntitlementServices::GrantUsage.new(user: user, reference: grant.reference)
        assert(service.call { 1.positive? })
        grant.reload
        expect(GrantUsage.count).to eq(count + 1)
        expect(grant.usages.count).to eq(1)
      end
      it 'should not create a usage if the block returns false' do
        count = GrantUsage.count
        expect(grant.usages.count).to eq(0)
        service = EntitlementServices::GrantUsage.new(user: user, reference: grant.reference)
        refute(service.call { 0.positive? })
        grant.reload
        expect(GrantUsage.count).to eq(count)
        expect(grant.usages.count).to eq(0)
      end
    end
  end
  describe 'with a non-effective Grant' do
    it 'should not create a usage' do
      grant.granted_at = Time.now + 1.day
      grant.save!
      count = GrantUsage.count
      expect(grant.usages.count).to eq(0)
      service = EntitlementServices::GrantUsage.new(user: user, reference: grant.reference)
      refute(service.call)
      expect(GrantUsage.count).to eq(count)
    end
  end
end
