#  frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  render_views

  include_context 'users'

  describe 'GET #index' do
    describe 'as an authenticated user' do
      before(:each) { sign_in facilitator }
      it 'should should succeed' do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:index_facilitator)
      end
      it 'should succeed with a locale parameter' do
        get :index, params: { locale: 'en' }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:index_facilitator)
      end
    end
  end

  describe 'GET #request_consent' do
    describe 'as an authenticated user' do
      before(:each) { sign_in facilitator }
      it 'should succeed' do
        get :request_consent
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:request_consent)
      end
    end
    describe 'as an unauthenticated user' do
      it 'should fail' do
        get :request_consent
        expect(response).to be_redirect
      end
    end
  end

  describe 'POST #grant_consent' do
    describe 'as an authenticated user' do
      let(:consent_params) { UserProfile::CONSENT_PARAMS.each_with_object({}) { |obj, memo| memo[obj] = '1'; } }
      before(:each) { sign_in facilitator }
      it 'should grant consent' do
        UserProfile::CONSENT_PARAMS.each { |key| facilitator.revoke_consent(key) }
        post :grant_consent, params: consent_params
        expect(response).to redirect_to(root_path)
      end
    end
    describe 'as an unauthenticated user'
  end

  describe 'Site requires consent in general' do
    describe 'as an authenticated user' do
      before(:each) { sign_in facilitator }
      describe 'with pending consents' do
        before(:each) do
          UserProfile::CONSENT_PARAMS.each do |key|
            facilitator.revoke_consent(key)
            facilitator.reload
          end
        end
        it 'should redirect to consent page' do
          expect(facilitator.required_consents_pending).to_not be_empty
          get :index
          expect(response).to redirect_to(request_consent_path)
        end
      end
      describe 'without pending consents'
    end
  end
end
