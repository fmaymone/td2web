# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationsController, type: :controller do
  render_views
  include_context 'users'

  let(:valid_attributes) { attributes_for(:organization) }
  let(:invalid_attributes) { attributes_for(:organization).merge(name: nil) }
  let(:updated_valid_organization_attributes) { { name: 'Foobar 2' } }
  let(:updated_invalid_organization_attributes) { { name: organization2.name } }
  let(:organization) do
    OrganizationServices::Creator.new(user: facilitator, params: valid_attributes).call
  end
  let(:organization2) do
    service = OrganizationServices::Creator.new(user: facilitator2, params: attributes_for(:organization))
    service.call
  end

  describe 'GET #index' do
    describe 'Unauthenticated' do
      it 'should redirect' do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'Logged in as administator' do
      it 'should render the index page' do
        sign_in admin
        get :index
        expect(response).to render_template(:index)
      end
    end

    describe 'Logged in as staff' do
      it 'should render the index page' do
        sign_in staff
        get :index
        expect(response).to render_template(:index)
      end
    end
    describe 'Logged in as a facilitator' do
      it 'should render the index page' do
        sign_in facilitator
        get :index
        expect(response).to render_template(:index)
      end
    end
    describe 'Logged in as a member' do
      it 'redirect to login' do
        sign_in member
        get :index
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'GET #new' do
    describe 'Unauthenticated' do
      it 'should redirect' do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end
    describe 'Logged in as staff' do
      it 'should render the index page' do
        sign_in staff
        get :new
        expect(response).to render_template(:new)
      end
    end
    describe 'Logged in as a facilitator' do
      it 'should render the index page' do
        sign_in facilitator
        get :new
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST #create' do
    describe 'Unauthenticated' do
      it 'should redirect' do
        post :create, params: {}
        expect(response).to redirect_to new_user_session_path
      end
    end
    describe 'Logged in as staff' do
      it 'should create a new organization assigned to the specified user' do
        sign_in staff
        org_count = Organization.count
        post :create, params: { organization: valid_attributes, user_id: facilitator.id }
        expect(Organization.count).to eq(org_count + 1)
        new_organization = assigns[:service].organization
        expect(response).to redirect_to organization_path(new_organization.id)
        expect(new_organization.members).to include(facilitator)
        expect(facilitator.organizations).to include(new_organization)
      end
    end
    describe 'Logged in as a facilitator ' do
      it 'should create a new organization assigned to them' do
        sign_in facilitator
        org_count = Organization.count
        post :create, params: { organization: valid_attributes }
        expect(Organization.count).to eq(org_count + 1)
        new_organization = assigns[:service].organization
        expect(response).to redirect_to organization_path(new_organization.id)
        expect(new_organization.members).to include(facilitator)
        expect(facilitator.organizations).to include(new_organization)
      end
    end
    describe 'Logged in as a member ' do
      it 'should redirect to home' do
        sign_in member
        org_count = Organization.count
        post :create, params: { organization: valid_attributes }
        expect(Organization.count).to eq(org_count)
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'GET #show' do
    describe 'as a facilitator' do
      it 'should display own organization' do
        organization
        sign_in facilitator
        get :show, params: { id: organization.id }
        expect(response).to render_template(:show)
      end
      it 'should not display others organization' do
        organization
        sign_in facilitator
        expect { get :show, params: { id: organization2.id } }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe 'GET ' do
    describe 'as a facilitator' do
      it 'should display edit form for own organization' do
        organization
        sign_in facilitator
        get :edit, params: { id: organization.id }
        expect(response).to render_template(:edit)
      end
      it 'should not display others organization' do
        organization
        sign_in facilitator
        expect { get :edit, params: { id: organization2.id } }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe 'PUT #update' do
    describe 'as a facilitator' do
      describe 'when using valid attributes' do
        it 'should update own organization' do
          organization
          sign_in facilitator
          put :update, params: { organization: updated_valid_organization_attributes, id: organization.id }
          expect(response).to redirect_to(organization_path(organization))
          organization.reload
          expect(organization.name).to eq('Foobar 2')
        end
        it 'should not update others organization' do
          organization
          sign_in facilitator
          expect { get :edit, params: { id: organization2.id } }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    describe 'as a facilitator' do
      before(:each) do
        organization
        organization2
      end
      it 'should delete own organization' do
        sign_in facilitator
        org_count = Organization.count
        delete :destroy, params: { id: organization.id }
        expect(response).to redirect_to(organizations_path)
        expect(Organization.count).to eq(org_count - 1)
      end
      it 'should not delete others organization' do
        sign_in facilitator
        org_count = Organization.count
        expect { delete :destroy, params: { id: organization2.id } }.to raise_error(ActiveRecord::RecordNotFound)
        expect(Organization.count).to eq(org_count)
      end
    end
  end
end
