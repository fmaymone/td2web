# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Entitlement, type: :model do
  let(:entitlement) { build(:entitlement) }
  describe 'initialization' do
    it 'can be initialized' do
      new_entitlement = Entitlement.new
      refute(new_entitlement.valid?)
    end

    it 'can be saved' do
      assert(entitlement.save)
    end
  end
end
