# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/new', type: :view do
  before(:each) do
    assign(:organization, Organization.new(
                            name: 'MyString',
                            slug: 'MyString',
                            domain: 'MyString',
                            description: 'MyText',
                            active: false
                          ))
  end

  it 'renders new organization form' do
    render

    assert_select 'form[action=?][method=?]', organizations_path, 'post' do
      assert_select 'input[name=?]', 'organization[name]'

      assert_select 'input[name=?]', 'organization[slug]'

      assert_select 'input[name=?]', 'organization[domain]'

      assert_select 'textarea[name=?]', 'organization[description]'

      assert_select 'input[name=?]', 'organization[active]'
    end
  end
end
