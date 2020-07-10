# frozen_string_literal: true

RSpec.describe GlobalizeCountry, type: :model do
  describe 'Initialization' do
    it 'should be initialized' do
      expect(GlobalizeCountry.new).to be_a(GlobalizeCountry)
    end
  end
end
