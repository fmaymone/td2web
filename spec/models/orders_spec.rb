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
    describe 'calculations' do
      before(:each) { order_items }
      it 'returns the total from all OrderItems' do
        expect(order.subtotal).to eq(0.0)
        expect(order.total).to eq(0.0)
        order.calculate_total
        expect(order.subtotal).to_not eq(0.0)
        expect(order.total).to_not eq(0.0)
      end
    end
  end
end
