# frozen_string_literal: true

# == Schema Information
#
# Table name: order_discounts
#
#  id          :uuid             not null, primary key
#  order_id    :uuid             not null
#  coupon_id   :uuid             not null
#  description :string           not null
#  total       :decimal(, )      default(0.0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class OrderDiscount < ApplicationRecord
  belongs_to :order
  belongs_to :coupon
end
