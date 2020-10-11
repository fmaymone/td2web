# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invitation, type: :model do
  include_context 'users'

  let(:valid_attributes) { attributes_for(:invitation) }

  describe 'initialization' do
    it 'can be saved' do
      invitation = build(:invitation, grantor: admin)
      assert(invitation.save)
    end

    it 'generates a token' do
      invitation = build(:invitation, grantor: admin)
      refute(invitation.token.present?)
      assert(invitation.save)
      assert(invitation.token.present?)
    end
  end
end
