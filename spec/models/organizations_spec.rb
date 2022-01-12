# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization, type: :mode, metadate: true do
  describe 'initialization' do
    it 'can create a new organization' do
      organization = build(:organization)
      assert(organization.save)
    end

    describe 'validations' do
      it 'requires a name' do
        organization = build(:organization, name: nil)
        refute(organization.save)
      end
      it 'requires an industry' do
        organization = build(:organization, industry: nil)
        refute(organization.save)
      end
      it 'requires a revenue' do
        organization = build(:organization, revenue: nil)
        refute(organization.save)
      end
      it 'requires a locale' do
        organization = build(:organization, locale: nil)
        refute(organization.save)
      end
      it 'does not need to have a unique name' do
        tenant1 = create(:tenant)
        tenant2 = create(:tenant)
        name = 'Acme, Inc.'
        organization1 = build(:organization, name:, tenant: tenant1)
        organization2 = build(:organization, name:, tenant: tenant2)
        organization3 = build(:organization, name:, tenant: tenant1)
        assert(organization1.save)
        assert(organization2.save)
        assert(organization3.save)
      end
    end
  end
end
