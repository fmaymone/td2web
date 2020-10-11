# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Grant, type: :model do
  include_context 'users'

  let(:grant) { build(:grant, user: staff, grantor: admin) }
  let(:valid_attributes) { attributes_for(:grant, user: staff, grantor: admin) }

  describe 'initialization' do
    it 'is successful' do
      assert(grant.save)
    end
  end
end
