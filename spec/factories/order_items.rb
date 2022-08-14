# frozen_string_literal: true

# == Schema Information
#
# Table name: order_items
#
#  id          :uuid             not null, primary key
#  order_id    :uuid             not null
#  product_id  :uuid             not null
#  description :string           not null
#  quantity    :integer          default(0), not null
#  unit_price  :decimal(, )      default(0.0), not null
#  total       :decimal(, )      default(0.0), not null
#  index       :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :order_item do
    association :order
    association :product
    description { product.description }
    unit_price { product.price }
    quantity { rand(1..10) }
    total { unit_price * quantity }
  end
end
