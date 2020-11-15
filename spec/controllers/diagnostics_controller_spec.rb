# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosticsController, type: :controller do
  render_views
  include_context 'users'
  include_context 'diagnostics'

  describe 'Logged in as an Admin' do
    before(:each) { sign_in admin }
    let(:valid_attributes) { attributes_for(:diagnostic) }
    let(:invalid_attributes) { { name: nil } }
    let(:diagnostic) { create(:diagnostic) }

    describe 'GET /index' do
      before(:each) { diagnostic_seed_data }
      it 'should be successful' do
        get :index
        expect(response).to be_successful
      end
    end
    describe 'GET /show' do
      it 'should be successful' do
        get :show, params: { id: team_diagnostic.id }
        expect(response).to be_successful
      end
    end
    describe 'GET /new' do
      it 'should be successful' do
        get :new
        expect(response).to be_successful
      end
    end
    describe 'POST /create' do
      describe 'with valid attributes' do
        it 'should create a new diagnostic' do
          diagnostic_count = Diagnostic.count
          post :create, params: { diagnostic: valid_attributes }
          expect(response).to redirect_to(diagnostic_path(assigns(:diagnostic)))
          expect(Diagnostic.count).to eq(diagnostic_count + 1)
        end
      end
      describe 'with invalid attributes' do
        it 'should fail and rerender the form' do
          diagnostic_count = Diagnostic.count
          post :create, params: { diagnostic: invalid_attributes }
          expect(response).to render_template('new')
          expect(Diagnostic.count).to eq(diagnostic_count)
        end
      end
    end
    describe 'GET /edit' do
      it 'should render the edit form' do
        get :edit, params: { id: team_diagnostic.id }
        expect(response).to render_template('edit')
      end
    end
    describe 'PUT /update' do
      describe 'with valid attributes' do
        it 'should update the diagnostic' do
          new_name = 'foobar'
          put :update, params: { id: team_diagnostic.id, diagnostic: { name: new_name } }
          team_diagnostic.reload
          expect(response).to redirect_to(diagnostic_path(team_diagnostic))
          expect(team_diagnostic.name).to eq(new_name)
        end
      end
      describe 'with invalid attributes' do
        it 'should not update the diagnostic and rerender the form' do
          new_name = nil
          old_name = team_diagnostic.name
          put :update, params: { id: team_diagnostic.id, diagnostic: { name: new_name } }
          team_diagnostic.reload
          expect(response).to render_template('edit')
          expect(team_diagnostic.name).to eq(old_name)
        end
      end
    end
    describe 'DELETE /destroy' do
      it 'raise an error' do
        expect  do
          delete :destroy, params: { id: team_diagnostic.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'Logged in as a Facilitator' do
    before(:each) { sign_in facilitator }
    describe 'GET /index' do
      it 'should disallow access' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end
    describe 'GET /edit' do
      it 'should disallow access' do
        expect do
          get :edit, params: { id: team_diagnostic.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
