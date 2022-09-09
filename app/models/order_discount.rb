# frozen_string_literal: true

# == Schema Information
#
# Table name: order_discounts
#
#  id            :uuid             not null, primary key
#  order_id      :uuid             not null
#  coupon_id     :uuid             not null
#  order_item_id :uuid
#  description   :string           not null
#  total         :decimal(, )      default(0.0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class OrderDiscount < ApplicationRecord
  ### Associations
  belongs_to :order
  belongs_to :coupon
  belongs_to :order_item, optional: true

  ### Validations
  validates :description, presence: true
  validates :total, presence: true, numericality: { greater_than: 0.0 }
  validates :coupon_id, uniqueness: { scope: :order_item_id },
                        if: -> { coupon_id.present? }
end
