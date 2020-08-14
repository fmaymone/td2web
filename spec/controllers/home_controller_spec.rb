#  frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  render_views

  describe 'GET #index' do
    let(:tenant) { create(:tenant, slug: 'default') unless Tenant.find_by_slug('default') }
    before(:each) do
      tenant
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
