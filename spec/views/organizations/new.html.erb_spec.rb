# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'tenants/new', type: :view do
  before(:each) do
    assign(:tenant, Tenant.new(
                      name: 'MyString',
                      slug: 'MyString',
                      domain: 'MyString',
                      description: 'MyText',
                      active: false
                    ))
  end

  it 'renders new tenant form' do
    render

    assert_select 'form[action=?][method=?]', tenants_path, 'post' do
      assert_select 'input[name=?]', 'tenant[name]'

      assert_select 'input[name=?]', 'tenant[slug]'

      assert_select 'input[name=?]', 'tenant[domain]'

      assert_select 'textarea[name=?]', 'tenant[description]'

      assert_select 'input[name=?]', 'tenant[active]'
    end
  end
end
