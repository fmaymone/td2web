# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntitlementsController, type: :controller do
  render_views
  include_context 'users'

  describe 'Logged in as an admin' do
    before(:each) { sign_in admin }

    let(:valid_attributes) { attributes_for(:entitlement) }
    let(:invalid_attributes) { { quota: 1 } }
    let(:entitlement) { create(:entitlement) }

    describe 'GET /index' do
      it 'renders a successful response' do
        entitlement
        get :index
        expect(response).to be_successful
      end
    end

    describe 'GET /new' do
      it 'renders a successful response' do
        get :new
        expect(response).to be_successful
      end
    end

    describe 'POST /create' do
      describe 'with valid attributes' do
        it 'should create a new entitlement' do
          count = Entitlement.count
          entitlement = Entitlement.new(valid_attributes)
          assert(entitlement.valid?)
          post :create, params: { entitlement: valid_attributes }
          expect(Entitlement.count).to eq(count + 1)
          expect(response).to be_a_redirect
        end
      end
      describe 'with invalid attributes' do
        it 'should re-render the form' do
          count = Entitlement.count
          post :create, params: { entitlement: invalid_attributes }
          expect(Entitlement.count).to eq(count)
          expect(response).to render_template(:new)
        end
      end
    end

    describe 'GET /show' do
      it 'renders a successful response' do
        entitlement
        get :show, params: { id: entitlement.id }
        expect(response).to be_successful
      end
    end

    describe 'GET /edit' do
      it 'renders a successful response' do
        entitlement
        get :edit, params: { id: entitlement.id }
        expect(response).to be_successful
      end
    end

    describe 'PUT /update' do
      let(:updated_attributes) { { description: 'foobar' } }
      let(:invalid_updated_attributes) { { reference: '' } }

      describe 'with valid attributes' do
        it ' should update the record' do
          put :update, params: { entitlement: updated_attributes, id: entitlement.id }
          entitlement.reload
          expect(response).to redirect_to(entitlement_path(entitlement))
          expect(entitlement.description).to eq('foobar')
        end
      end

      describe 'with invalid attributes' do
        it 'should not update the record' do
          old_reference = entitlement.reference
          put :update, params: { entitlement: invalid_updated_attributes, id: entitlement.id }
          entitlement.reload
          expect(response).to render_template(:edit)
          expect(entitlement.reference).to eq(old_reference)
        end
      end
    end

    describe 'DELETE /destroy' do
      it 'should delete the record' do
        entitlement
        count = Entitlement.count
        delete :destroy, params: { id: entitlement.id }
        expect(response).to redirect_to(entitlements_path)
        expect(Entitlement.count).to eq(count - 1)
      end
    end
  end
end
