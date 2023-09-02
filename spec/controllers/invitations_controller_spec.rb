# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvitationsController, type: :controller do
  render_views
  include_context 'users'
  include_context 'entitlements'
  include_context 'invitations'

  describe 'logged in as a staff member' do
    before(:each) do
      registration_invitation
      sign_in staff
    end

    let(:valid_attributes) { attributes_for(:invitation) }
    let(:invalid_attributes) { attributes_for(:invitation, email: nil) }

    describe 'GET /index' do
      it 'should succeed' do
        get :index
        expect(response).to be_successful
      end
    end

    describe 'GET /new' do
      it 'should succeed' do
        get :new
        expect(response).to be_successful
        invitation = assigns(:invitation)

        expect(invitation.entitlements.size).to be > (1)
      end
    end

    describe 'POST /create' do
      describe 'with valid attributes' do
        it 'should create a new invitation' do
          count = Invitation.count
          post :create, params: { invitation: valid_attributes }
          expect(response).to redirect_to(invitations_path)
          expect(Invitation.count).to eq(count + 1)
        end
      end

      describe 'with invalid attributes' do
        it 'should fail and rerender the form' do
          count = Invitation.count
          post :create, params: { invitation: invalid_attributes }
          expect(response).to render_template('new')
          expect(Invitation.count).to eq(count)
        end
      end

      describe 'GET /show' do
        it 'should render the show template' do
          get :show, params: { id: registration_invitation.id }
          expect(response).to render_template('show')
        end
      end

      describe 'DELETE /destroy' do
        it 'should deactivate the invitation' do
          assert(registration_invitation.valid?)
          count = Invitation.count
          delete :destroy, params: { id: registration_invitation.id }
          expect(response).to redirect_to(invitations_path)
          registration_invitation.reload
          expect(Invitation.count).to eq(count)
          refute(registration_invitation.active?)
        end
      end
    end
  end

  describe 'as an unauthenticated user' do
    describe 'GET /claim' do
      it 'should render the claim form' do
        get :claim, params: { token: registration_invitation.token }
        expect(response).to render_template('claim')
      end
    end

    describe 'POST /process_claim' do
      describe 'with a valid token' do
        it 'should redirect' do
          post :process_claim, params: { token: registration_invitation.token }
          expect(response).to redirect_to(registration_invitation.redirect + "?invitation_id=#{registration_invitation.id}")
        end
      end
      describe 'with an invalid token' do
        it 'should render the form' do
          post :process_claim, params: { token: 'invalid' }
          expect(response).to render_template('claim')
        end
      end
    end
  end
end
