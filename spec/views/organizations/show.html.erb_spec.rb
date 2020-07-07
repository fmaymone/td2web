# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/show', type: :view do
  include_context 'default_organization'
  before(:each) do
    @organization = assign(:organization, default_organization)
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(default_organization.slug)
  end
end
