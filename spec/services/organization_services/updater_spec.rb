# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationServices::Updater do
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
  let(:new_valid_attributes) { { name: 'Dewey, Cheatem, and Howe' } }
  let(:invalid_attributes) { { name: nil, industry: 'Not a valid option' } }

  let(:admin_own_organization) { OrganizationServices::Creator.new(user: admin, params: valid_attributes).call }
  let(:facilitator_organization) { OrganizationServices::Creator.new(user: facilitator, params: valid_attributes).call }
  let(:other_organization) { OrganizationServices::Creator.new(user: facilitator2, params: valid_attributes).call }

  describe 'as an admin' do
    describe 'updating own organization' do
      describe 'with invalid attributes' do
        it 'should not update the organization' do
          old_name = admin_own_organization.name
          service = OrganizationServices::Updater.new(user: admin, params: invalid_attributes.merge(id: admin_own_organization.id))
          refute(service.call)
          admin_own_organization.reload
          expect(admin_own_organization.name).to eq(old_name)
        end
      end
      describe 'with valid attributes' do
        it 'should update the organization' do
          old_name = admin_own_organization.name
          service = OrganizationServices::Updater.new(user: admin, params: new_valid_attributes.merge(id: admin_own_organization.id))
          assert(service.call)
          admin_own_organization.reload
          expect(admin_own_organization.name).to_not eq(old_name)
        end
      end
    end
    describe 'updating other\'s organization' do
      it 'should update the organization' do
        old_name = other_organization.name
        service = OrganizationServices::Updater.new(user: admin, params: new_valid_attributes.merge(id: other_organization.id))
        assert(service.call)
        other_organization.reload
        expect(other_organization.name).to_not eq(old_name)
      end
    end
  end
  describe 'as a facilitator' do
    describe 'updating own organization' do
      it 'should update the organization' do
        old_name = facilitator_organization.name
        service = OrganizationServices::Updater.new(user: facilitator, params: new_valid_attributes.merge(id: facilitator_organization.id))
        assert(service.call)
        facilitator_organization.reload
        expect(facilitator_organization.name).to_not eq(old_name)
      end
    end
    describe 'updating other\'s organization' do
      it 'should fail and not update the organization' do
        old_name = other_organization.name
        service = OrganizationServices::Updater.new(user: facilitator, params: new_valid_attributes.merge(id: other_organization.id))
        refute(service.call)
        other_organization.reload
        expect(other_organization.name).to eq(old_name)
      end
    end
  end
end
