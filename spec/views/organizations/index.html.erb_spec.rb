# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'tenants/index', type: :view do
  let(:tenant1) { create(:tenant) }
  let(:tenant2) { create(:tenant) }
  before(:each) do
    assign(:tenants, [tenant1, tenant2])
  end

  it 'renders a list of tenants' do
    render
    assert_select 'tr>td', text: tenant1.name, count: 1
    assert_select 'tr>td', text: tenant2.name, count: 1
  end
end
