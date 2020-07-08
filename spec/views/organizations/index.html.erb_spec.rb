# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/index', type: :view do
  let(:organization1) { create(:organization) }
  let(:organization2) { create(:organization) }
  before(:each) do
    assign(:organizations, [organization1, organization2])
  end

  it 'renders a list of organizations' do
    render
    assert_select 'tr>td', text: organization1.name, count: 1
    assert_select 'tr>td', text: organization2.name, count: 1
  end
end
