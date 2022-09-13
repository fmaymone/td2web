# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'initialization' do
    it 'creates a product' do
      assert(create(:product))
    end
  end

  describe 'volume pricing' do
    let(:product_attrs) do
      {
        volume_pricing: {
          '1' => 123.45,
          '10' => 100,
          '50' => 50.0
        }
      }
    end
    let(:invalid_product_attrs) do
      {
        volume_pricing: {
          '1' => -1,
          '10' => -1,
          '50' => 50.0
        }
      }
    end
    let(:product_without_volume) do
      p = create(:product)
      p.volume_pricing = {}
      p.save
      p
    end
    let(:product_with_volume) { create(:product, volume_pricing: product_attrs[:volume_pricing]) }
    let(:product_with_invalid_volume) { create(:product, volume_pricing: invalid_product_attrs[:volume_pricing]) }

    it 'defaults to the product price with a quantity of 1' do
      product = product_without_volume
      expect(product.effective_price(-1)).to eq(product.price)
      expect(product.effective_price(0)).to eq(product.price)
      expect(product.effective_price(1)).to eq(product.price)
    end

    it 'provides effective price for volume pricing' do
      product = product_with_volume

      expect(product.effective_price(-1)).to eq(product.price)
      expect(product.effective_price(0)).to eq(product.price)
      expect(product.effective_price(1)).to eq(product.price)
      expect(product.effective_price(10)).to eq(product_attrs[:volume_pricing]['10'])
      expect(product.effective_price(11)).to eq(product_attrs[:volume_pricing]['10'])
      expect(product.effective_price(50)).to eq(product_attrs[:volume_pricing]['50'])
      expect(product.effective_price(51)).to eq(product_attrs[:volume_pricing]['50'])
      expect(product.effective_price(1001)).to eq(product_attrs[:volume_pricing]['50'])
    end

    it 'handles invalid volume pricing data' do
      product = product_with_invalid_volume
      expect(product.effective_price(10)).to eq(product.price)
    end
  end
end
