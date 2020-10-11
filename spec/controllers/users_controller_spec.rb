# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views
  include_context 'users'

  let(:valid_attributes) do
    attributes_for(:user, role_id: facilitator_role.id)
  end
  let(:invalid_attributes) { valid_attributes.merge(username: nil) }

  describe 'GET #index' do
    describe 'Logged in as an Admin' do
      before(:each) { sign_in admin }
      it 'renders a successful response' do
        get :index
        expect(response).to be_successful
        expect(response).to render_template('index')
      end
    end

    describe 'Logged in as staff user' do
      before(:each) { sign_in staff }
      it 'renders a successful response' do
        get :index
        expect(response).to be_successful
        expect(response).to render_template('index')
      end
    end

    describe 'Logged in as a translator' do
      before(:each) { sign_in translator }
      it 'redirects away from the page' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'Logged in as a facilitator' do
      before(:each) { sign_in facilitator }
      it 'redirects away from the page' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end
    describe 'Logged in as a team member' do
      before(:each) { sign_in member }
      it 'redirects away from the page' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end
    describe 'Logged in as a translator' do
      before(:each) { sign_in translator }
      it 'redirects away from the page' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'As an unauthenticated user' do
      it 'redirects to login' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #new' do
    describe 'Logged in as an Admin' do
      before(:each) { sign_in admin }
      it 'renders a successful response' do
        get :new
        expect(response).to be_successful
        expect(response).to render_template('new')
      end
    end
  end

  describe 'POST #create' do
    describe 'Logged in as an Admin' do
      before(:each) { sign_in admin }
      describe 'with valid attributes' do
        it 'creates a new user' do
          count = User.count
          post :create, params: { user: valid_attributes }
          expect(assigns[:user].username).to eq(valid_attributes[:username])
          expect(response).to redirect_to(user_path(assigns[:user]))
          expect(User.count).to eq(count + 1)
        end
      end
      describe 'with invalid attributes' do
        it 'creates a new user' do
          count = User.count
          post :create, params: { user: invalid_attributes }
          expect(User.count).to eq(count)
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'GET #show' do
    describe 'Logged in as an Admin' do
      before(:each) { sign_in admin }
      let(:user) { full_featured_user }
      it 'is successful' do
        get :show, params: { id: user.id }
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'GET #edit' do
    describe 'Logged in as an Admin' do
      before(:each) { sign_in admin }
      let(:user) { staff }
      it 'is successful' do
        get :edit, params: { id: user.id }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'PUT #update' do
    describe 'Logged in as an Admin' do
      before(:each) { sign_in admin }
      let(:user) { staff }
      let(:new_username) { '12341212' }
      let(:new_valid_attributes) { { username: new_username } }
      let(:new_invalid_attributes) { { username: nil } }
      describe 'with valid attributes' do
        it 'is successful' do
          put :update, params: { id: user.id, user: new_valid_attributes }
          expect(response).to redirect_to(user_path(user))
          user.reload
          expect(user.username).to eq(new_username)
        end
      end
      describe 'with invalid attributes' do
        it 'should not update the user' do
          old_username = user.username
          put :update, params: { id: user.id, user: new_invalid_attributes }
          expect(response).to render_template(:edit)
          user.reload
          expect(user.username).to eq(old_username)
        end
      end
    end

    describe 'DELETE #destroy' do
      describe 'Logged in as an Admin' do
        before(:each) { sign_in admin }
        let(:user) { staff }
        it 'will lock a user account' do
          user
          count = User.count
          refute(user.locked?)
          delete :destroy, params: { id: user.id }
          expect(response).to redirect_to(users_path)
          expect(User.count).to eq(count)
          user.reload
          assert(user.locked?)
        end
        it 'will unlock a user account' do
          user.lock_access!
          user.reload
          count = User.count
          assert(user.locked?)
          delete :destroy, params: { id: user.id, unlock: true }
          expect(response).to redirect_to(users_path)
          expect(User.count).to eq(count)
          user.reload
          refute(user.locked?)
        end
      end
    end
  end

  describe 'GET #consent' do
  end
end
