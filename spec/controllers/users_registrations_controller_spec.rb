# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  render_views
  include_context 'users'
  include_context 'invitations'

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    registration_invitation
  end

  describe 'GET #new' do
    describe 'as an unauthenticated user' do
      it 'should succeed' do
        get :new, params: { invitation_id: registration_invitation.id }
        expect(response).to be_successful
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) { attributes_for(:user) }
    let(:invalid_params) { valid_params.merge(username: nil) }
    describe 'with valid params' do
      it 'should create a user' do
        count = User.count
        post :create, params: { invitation_id: registration_invitation.id, user: valid_params }
        expect(User.count).to eq(count + 1)
        expect(response).to redirect_to(after_registration_path)
        expect(User.order(created_at: :desc).first.role).to eq(registration_entitlement.role)
      end
    end
    describe 'with invalid params' do
      it 'should re-render the form' do
        count = User.count
        post :create, params: { invitation_id: registration_invitation.id, user: invalid_params }
        expect(User.count).to eq(count)
        expect(response).to render_template(:new)
      end
    end
  end
end
