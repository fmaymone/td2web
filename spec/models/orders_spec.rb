# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  include_context 'team_diagnostics'

  let(:team_diagnostic) { completed_teamdiagnostic }
  let(:user) { team_diagnostic.user }

  describe 'initialization' do
    describe 'orderid' do
      it 'generates an orderid on create' do
        order = build(:order, user:, orderable: team_diagnostic, orderid: nil)
        refute(order.orderid.present?)
        assert(order.save)
        assert(order.orderid.present?)
      end
    end
  end

  describe 'validations' do
    it 'has a unique orderid' do
      order1 = create(:order, user:, orderable: team_diagnostic, orderid: nil)
      order2 = build(:order, user:, orderable: team_diagnostic, orderid: order1.orderid)
      refute(order2.save)
      order2.orderid = nil
      assert(order2.save)
      assert(order2.orderid.present?)
      expect(order2.orderid).to_not eq(order1.orderid)
    end
  end

  describe 'state machine' do
    it 'creates an invoice upon submit event'
    it 'must have an accepted invoice to transition to paid'
  end

  describe 'invoicing' do
    let(:products) do
      Product.load_seed_data
      Product.all
    end
    let(:order) { create(:order, user:, orderable: team_diagnostic, total: 0.0, subtotal: 0.0, tax: 0.0) }
    let(:order_items) do
      [
        create(:order_item, order:, product: products.sample),
        create(:order_item, order:, product: products.sample),
        create(:order_item, order:, product: products.sample)
      ]
    end
    let(:coupons) do
      [
        create(:coupon, product: products.sample, owner: team_diagnostic.user),
        create(:coupon, product: products.sample, owner: team_diagnostic.user),
        create(:coupon, product: products.sample, owner: team_diagnostic.user)
      ]
    end
    let(:order_discounts) do
      coupons.map do |coupon|
        create(:order_discount, order:, coupon:)
      end
    end
    describe 'calculations' do
      before(:each) { order_items }
      it 'returns the total from all OrderItems' do
        expect(order.items_total).to eq(order_items.map(&:total).sum)
      end
      # it 'returns the total from all OrderDiscounts' do
      # expect(order.discounts_total).to eq(coupons.map(&:total).sum)
      # end
      it 'returns the total from all OrderItems and OrderDiscounts' do
        expect(order.subtotal).to eq(0.0)
        expect(order.total).to eq(0.0)
        order.calculate_total!
        expect(order.subtotal).to_not eq(0.0)
        expect(order.total).to_not eq(0.0)
      end
    end
  end
end
