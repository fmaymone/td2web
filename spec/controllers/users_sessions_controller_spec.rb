# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  render_views

  include_context 'users'

  describe 'GET #new' do
    before(:each) { @request.env['devise.mapping'] = Devise.mappings[:user] }
    describe 'as an unauthenticated user' do
      it 'should succeed' do
        get :new
        expect(response).to be_successful
      end
    end
  end
end
