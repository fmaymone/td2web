# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GrantsController, type: :controller do
  render_views
  include_context 'users'

  let(:entitlement) { create(:entitlement) }
  let(:entitlement2) { create(:entitlement) }

  describe 'Logged in as admin' do
    before(:each) { sign_in admin }

    let(:valid_attributes) { attributes_for(:grant, reference: entitlement.reference, entitlement_id: entitlement.id, user_id: grantee.id, grantor_id: admin.id, grantor_type: 'User') }
    let(:invalid_attributes) { attributes_for(:grant, reference: nil, entitlement_id: nil) }
    let(:grantee) { staff }
    let(:grant) { create(:grant, user_id: grantee.id, grantor_id: admin.id, grantor_type: 'User', entitlement_id: entitlement.id) }

    describe 'GET  /index' do
      it 'access denied' do
        get :index, params: { user_id: grantee.id }
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'GET  /show' do
      it 'access denied' do
        get :show, params: { id: grant.id, user_id: grantee.id }
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'GET /new' do
      it 'should render the grant form' do
        get :new, params: { user_id: grantee.id }
        expect(response).to render_template('new')
      end
    end

    describe 'POST /create' do
      describe 'with valid attributes' do
        it 'should create a new grant' do
          grant_count = grantee.grants.count
          post :create, params: { user_id: grantee.id, grant: valid_attributes }
          grantee.reload
          expect(assigns[:grant].errors.full_messages).to eq([])
          expect(grantee.grants.count).to eq(grant_count + 1)
          expect(response).to redirect_to(user_path(grantee))
        end
      end

      describe 'with invalid attributes' do
        it 'should not create a new grant' do
          grant_count = grantee.grants.count
          post :create, params: { user_id: grantee.id, grant: invalid_attributes }
          expect(response).to render_template(:new)
          grantee.reload
          expect(grantee.grants.count).to eq(grant_count)
        end
      end
    end

    describe 'GET /edit' do
      it 'should render the edit form' do
        get :edit, params: { id: grant.id, user_id: grantee.id }
        expect(response).to render_template(:edit)
      end
    end

    describe 'PUT /update' do
      let(:valid_attributes) { { quota: 999 } }
      describe 'with valid_attributes' do
        it 'should update the grant' do
          put :update, params: { id: grant.id, user_id: grantee.id, grant: valid_attributes }
          expect(response).to redirect_to(user_path(grantee))
          grant.reload
          expect(grant.quota).to eq(valid_attributes[:quota])
        end
      end

      describe 'with invalid attributes' do
        it 'should not update the grant' do
          old_quota = grant.quota
          put :update, params: { id: grant.id, user_id: grantee.id, grant: invalid_attributes }
          expect(response).to render_template(:edit)
          grant.reload
          expect(grant.quota).to eq(old_quota)
        end
      end
    end

    describe 'DELETE /destroy' do
      describe 'with the deactivate flag' do
        it 'should deactivate the grant' do
          assert(grant.active?)
          delete :destroy, params: { id: grant.id, user_id: grantee.id, deactivate: true }
          grant.reload
          refute(grant.active)
          expect(response).to redirect_to(user_path(grantee))
        end
      end
      describe 'without any flags' do
        it 'should delete the grant' do
          grant
          grant_count = grantee.grants.count
          delete :destroy, params: { id: grant.id, user_id: grantee.id }
          grantee.reload
          expect(response).to redirect_to(user_path(grantee))
          expect(grantee.grants.count).to eq(grant_count - 1)
        end
      end
    end
  end
end
