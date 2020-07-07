# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/edit', type: :view do
  include_context 'default_organization'
  before(:each) do
    @organization = assign(:organization, default_organization)
  end

  it 'renders the edit organization form' do
    render

    assert_select 'form[action=?][method=?]', organization_path(@organization), 'post' do
      assert_select 'input[name=?]', 'organization[name]'

      assert_select 'input[name=?]', 'organization[slug]'

      assert_select 'input[name=?]', 'organization[domain]'

      assert_select 'textarea[name=?]', 'organization[description]'

      assert_select 'input[name=?]', 'organization[active]'
    end
  end
end
