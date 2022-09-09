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
FactoryBot.define do
  factory :order_discount do
    association :order
    association :coupon
    description { Faker::Lorem.sentence }
    total { Faker::Commerce.price }
  end
end
