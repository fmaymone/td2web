# frozen_string_literal: true

module Orders
  # Order Coupons functionality
  module Coupons
    extend ActiveSupport::Concern

    class ApplyCouponError < StandardError; end

    included do
      def allow_add_coupon?
        state == 'finalized'
      end

      def apply_permanent_coupons!
        raise ApplyCouponError, 'Order must be finalized' unless allow_add_coupon?

        if orderable.respond_to?(:organization)
          orderable.organization.coupons.active.reuseable.each do |coupon|
            apply_coupon(coupon)
          rescue ApplyCouponError
            true
          end
        end

        user.coupons.active.reuseable.each do |coupon|
          apply_coupon(coupon)
        rescue ApplyCouponError
          true
        end

        true
      end

      def apply_coupon(coupon_or_code)
        raise ApplyCouponError, 'Order must be finalized' unless allow_add_coupon?

        order_organization = orderable.respond_to?(:organization) ? orderable.organization : nil
        coupon = case coupon_or_code
                 when Coupon
                   coupon_or_code
                 when String
                   user.coupons.where(code: coupon_or_code).limit(1).first ||
                   (orderable.respond_to?(:coupons) ? orderable.coupons.where(code: coupon_or_code).limit(1).first : nil) ||
                   order_organization.coupons.where(code: coupon_or_code).limit(1).first
                 end

        # What coupon?
        raise ActiveRecord::RecordNotFound unless coupon.present?

        # Reject duplicate coupon
        raise ApplyCouponError, 'Coupon is already applied to this Order' if order_discounts.where(coupon:).any?

        # Reject stacking a non-stackable coupon for the product or order as a whole
        raise ApplyCouponError, 'Coupon cannot be stacked on this Order' if !coupon.stackable? &&
                                                                            order_discounts.includes(:coupon).where(coupon: { product: coupon.product }).any?

        # Reject coupon if unusable
        raise ApplyCouponError, 'This Coupon is not applicable to this Order' unless order_items.any? do |item|
          coupon.usable?(for_owner: user, for_product: item.product) ||
          coupon.usable?(for_owner: orderable, for_product: item.product) ||
          coupon.usable?(for_owner: order_organization, for_product: item.product)
        end

        # Order-level discount
        if coupon.product.nil?
          whole_order_discount = (items_total * (1.0 / coupon.discount)).round(2)
          discount = order_discounts.create(
            order: self,
            coupon:,
            order_item_id: nil,
            description: coupon.description,
            total: whole_order_discount
          ) or raise(ApplyCouponError, 'Error creating Order Discount')

          order_discounts.reload
          return discount
        end

        if coupon.stackable?
          # Apply coupon to highest cost order item for the coupon product
          order_item = order_items
                       .where(product: coupon.product)
                       .order(total: :desc).limit(1).first
          raise(ApplyCouponError, 'This Coupon is not applicable to this Order') unless order_item.present?
        else
          # Apply coupon to highest cost order item for the coupon product
          order_item = order_items.includes(:order_discounts)
                                  .where(product: coupon.product, order_discounts: { id: nil })
                                  .order(total: :desc).limit(1).first
          raise ApplyCouponError, 'This Coupon cannot be stacked' unless order_item.present?
        end

        item_discount = (order_item.total * (1.0 / coupon.discount)).round(2)

        discount = order_discounts.create(
          order: self,
          order_item:,
          coupon:,
          description: coupon.description,
          total: item_discount
        ) or raise(ApplyCouponError, 'Error creating Order Discount')

        discount
      end
    end
  end
end
