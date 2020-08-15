# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::ConfirmationsController, type: :controller do
  render_views
  include_context 'users'

  before(:each) { @request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'GET #show' do
    let(:user_with_password) do
      user = build(:test_user)
      user.save
      user
    end
    let(:user_without_password) do
      user = build(:test_user)
      user.encrypted_password = ''
      user.save(validate: false)
      user
    end
    describe 'with a new and unconfirmed account without a password' do
      it 'should confirm the user and redirect to the new password page' do
        get :show, params: { confirmation_token: user_without_password.confirmation_token }
        expect(response).to redirect_to(new_user_password_path(user_without_password))
        user_without_password.reload
        expect(user_without_password.confirmed_at).to_not be_nil
      end
    end
    describe 'with a new and unconfirmed account with a password' do
      it 'should confirm the user and redirect to the homepage' do
        get :show, params: { confirmation_token: user_with_password.confirmation_token }
        expect(response).to redirect_to(root_path)
        user_with_password.reload
        expect(user_with_password.confirmed_at).to_not be_nil
      end
    end
  end
end
