# frozen_string_literal: true

RSpec.describe GlobalizeLanguage, type: :model do
  describe 'Initialization' do
    it 'should be initialized' do
      expect(GlobalizeLanguage.new).to be_a(GlobalizeLanguage)
    end
  end
end
