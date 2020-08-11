#  frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  render_views

  describe 'GET #index' do
    let(:organization) { create(:organization, slug: 'default') unless Organization.find_by_slug('default') }
    before(:each) do
      organization
    end
    it 'should should succeed' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end
    it 'should succeed with a locale parameter' do
      get :index, params: { locale: 'en' }
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end
  end
end