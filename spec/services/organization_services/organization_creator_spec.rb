# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationServices::Creator do
  include_context 'users'
  let(:grantor) { admin }
  let(:user) { facilitator }
  let(:valid_attributes) do
    {
      name: 'Acme, Inc.',
      description: 'Test organization',
      url: 'https://www.example.com/',
      industry: Organization.industries.keys.last,
      revenue: Organization.revenues.keys.last,
      locale: 'es'
    }
  end
  let(:invalid_attributes) do
    {
      name: nil,
      description: 'Test organization',
      url: 'https://www.example.com/',
      industry: Organization.industries.keys.last,
      revenue: Organization.revenues.keys.last,
      locale: 'es'
    }
  end

  describe 'as an admin' do
    describe 'creating a organization for self' do
      let(:service_with_valid_params) do
        OrganizationServices::Creator.new(user: admin, params: valid_attributes)
      end
      let(:service_with_invalid_params) do
        OrganizationServices::Creator.new(user: admin, params: invalid_attributes)
      end
      describe 'with valid attributes' do
        it 'should create the organization with admin membership' do
          service = service_with_valid_params
          org_count = Organization.count
          service.call
          assert(service.valid?)
          expect(Organization.count).to eq(org_count + 1)
          expect(admin.organizations.pluck(:id)).to include(service.organization.id)
          expect(admin.organization_role(service.organization)).to eq('admin')
        end
      end
      describe 'with invalid attributes' do
        it 'should not create an organization' do
          service = service_with_invalid_params
          org_count = Organization.count
          service.call
          refute(service.valid?)
          expect(Organization.count).to eq(org_count)
        end
      end
    end
    describe 'creating a organization for other user' do
      let(:service_with_valid_params) do
        OrganizationServices::Creator.new(user:, grantor: admin, params: valid_attributes)
      end
      let(:service_with_invalid_params) do
        OrganizationServices::Creator.new(user:, grantor: admin, params: invalid_attributes)
      end
      it 'should create the organization with user membership' do
        service = service_with_valid_params
        org_count = Organization.count
        service.call
        assert(service.valid?)
        expect(Organization.count).to eq(org_count + 1)
        expect(user.organizations.pluck(:id)).to include(service.organization.id)
      end
    end
  end
  describe 'as a facilitator with appropriate grants' do
    let(:service_with_valid_params) do
      OrganizationServices::Creator.new(user:, params: valid_attributes)
    end
    let(:service_with_invalid_params) do
      OrganizationServices::Creator.new(user:, params: invalid_attributes)
    end
    describe 'with valid params' do
      it 'should create the organization with user membership' do
        service = service_with_valid_params
        org_count = Organization.count
        service.call
        assert(service.valid?)
        expect(Organization.count).to eq(org_count + 1)
        expect(user.organizations.pluck(:id)).to include(service.organization.id)
        grant_usages = user.grants.where(reference: OrganizationServices::Creator::REFERENCE).valid.first.usage_count
        expect(grant_usages).to eq(1)
      end
    end
    describe 'with invalid params' do
      it 'should not create an organization' do
        service = service_with_invalid_params
        org_count = Organization.count
        service.call
        refute(service.valid?)
        expect(Organization.count).to eq(org_count)
        expect(user.organizations.pluck(:id)).to_not include(service.organization.id)
        grant_usages = user.grants.where(reference: OrganizationServices::Creator::REFERENCE).valid.first.usage_count
        expect(grant_usages).to eq(0)
      end
    end
  end
  describe 'as a facilitator without appropriate grants' do
    let(:service_with_valid_params) do
      OrganizationServices::Creator.new(user:, params: valid_attributes)
    end
    describe 'with valid params' do
      it 'should not create the organizationmembership' do
        user.grants.destroy_all
        service = service_with_valid_params
        org_count = Organization.count
        service.call
        refute(service.valid?)
        expect(Organization.count).to eq(org_count)
        expect(user.organizations.pluck(:id)).to_not include(service.organization.id)
      end
    end
  end
end
