# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'tenants/show', type: :view do
  include_context 'default_tenant'
  before(:each) do
    @tenant = assign(:tenant, default_tenant)
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(default_tenant.slug)
  end
end
