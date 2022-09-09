# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  include_context 'team_diagnostics'

  let(:user) { team_diagnostic.user }
  let(:team_diagnostic) { completed_teamdiagnostic }
  let(:product) do
    Product.load_seed_data
    team_diagnostic.diagnostic.product
  end
  let(:order) do
    new_order = create(:order, user:, orderable: team_diagnostic, state: :finalized)
    create(:order_item, order: new_order, product:)
    new_order.order_items.reload
    new_order
  end
  let(:user_coupon) { create(:coupon, owner: user, product:, stackable: false) }
  let(:stackable_user_coupon) { create(:coupon, owner: user, product:, stackable: true) }
  let(:organization_coupon) { create(:coupon, owner: team_diagnostic.organization, product:) }
  let(:reusable_organization_coupon) { create(:coupon, owner: team_diagnostic.organization, product:, reusable: true) }
  let(:reusable_user_coupon) { create(:coupon, owner: user, product:, reusable: true) }
  let(:inactive_reusable_user_coupon) { create(:coupon, owner: team_diagnostic.organization, product:, reusable: true) }
  let(:diagnostic_coupon) { create(:coupon, owner: team_diagnostic, product:, reusable: true) }

  describe 'individually adding coupons to order' do
    it 'returns whether any coupon can be added' do
      assert(order.allow_add_coupon?)
      order.update(state: :submitted)
      refute(order.allow_add_coupon?)
    end
    it 'accepts a valid coupon code' do
      # Owned by the user
      discount = order.apply_coupon(user_coupon.code)
      assert(discount.present?)
      order.order_discounts.reload
      expect(order.order_discounts).to include(discount)

      order.order_discounts.destroy_all

      # Owned by the organization
      discount = order.apply_coupon(organization_coupon.code)
      assert(discount.present?)
      order.order_discounts.reload
      expect(order.order_discounts).to include(discount)

      order.order_discounts.destroy_all

      # Assigned directly to the diagnostic
      discount = order.apply_coupon(diagnostic_coupon.code)
      assert(discount.present?)
      order.order_discounts.reload
      expect(order.order_discounts).to include(discount)
    end
    it 'applies a order-level coupon' do
      organization_coupon.update(product: nil)
      discount = order.apply_coupon(organization_coupon)
      assert(discount.present?)
      order.order_discounts.reload
      expect(order.order_discounts).to include(discount)
    end
    it 'prevents stacking non-stackable coupons' do
      expect(order.order_discounts.count).to eq(0)
      discount = order.apply_coupon(user_coupon)
      assert(discount.present?)
      order.order_discounts.reload
      expect(order.order_discounts.count).to eq(1)
      coupon2 = create(:coupon, product:, owner: user, stackable: false)
      expect do
        discount = order.apply_coupon(coupon2)
      end.to raise_error(Order::ApplyCouponError)
      order.order_discounts.reload
      expect(order.order_discounts.count).to eq(1)
    end
    it 'allows stacking stackable coupons' do
      expect(order.order_discounts.count).to eq(0)
      discount = order.apply_coupon(user_coupon)
      assert(discount.present?)
      order.order_discounts.reload
      expect(order.order_discounts.count).to eq(1)

      coupon2 = create(:coupon, product:, owner: user, stackable: true)
      discount = order.apply_coupon(coupon2)
      assert(discount.present?)
      order.order_discounts.reload
      expect(order.order_discounts.count).to eq(2)
    end
  end

  describe 'automatically adding reusable coupons to order' do
    it 'should automatically add only reusable user coupons' do
      reusable_user_coupon
      inactive_reusable_user_coupon
      expect(order.order_discounts.count).to eq(0)
      order.apply_permanent_coupons!
      order.order_discounts.reload
      expect(order.order_discounts.count).to eq(1)
    end
    it 'should automatically add only reusable organization coupons' do
      reusable_organization_coupon
      expect(order.order_discounts.count).to eq(0)
      order.apply_permanent_coupons!
      order.order_discounts.reload
      expect(order.order_discounts.count).to eq(1)
    end
  end
end
