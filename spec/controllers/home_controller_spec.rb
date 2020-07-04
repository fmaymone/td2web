#  frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  render_views

  describe 'GET #index' do
    it 'should should succeed' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end
  end
end
