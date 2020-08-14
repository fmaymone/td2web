# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'tenants/edit', type: :view do
  include_context 'default_tenant'
  before(:each) do
    @tenant = assign(:tenant, default_tenant)
  end

  it 'renders the edit tenant form' do
    render

    assert_select 'form[action=?][method=?]', tenant_path(@tenant), 'post' do
      assert_select 'input[name=?]', 'tenant[name]'

      assert_select 'input[name=?]', 'tenant[slug]'

      assert_select 'input[name=?]', 'tenant[domain]'

      assert_select 'textarea[name=?]', 'tenant[description]'

      assert_select 'input[name=?]', 'tenant[active]'
    end
  end
end
