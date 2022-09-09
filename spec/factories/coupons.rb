# frozen_string_literal: true

# == Schema Information
#
# Table name: coupons
#
#  id          :uuid             not null, primary key
#  code        :string           not null
#  description :string           not null
#  stackable   :boolean          default(FALSE), not null
#  active      :boolean          default(TRUE), not null
#  reusable    :boolean          default(FALSE), not null
#  start_date  :date
#  end_date    :date
#  discount    :integer          default(0), not null
#  product_id  :uuid
#  owner_id    :uuid
#  owner_type  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :coupon do
    association :product
    association :owner, factory: :user
    code { Faker::Alphanumeric.alphanumeric }
    description { Faker::Lorem.sentence }
    stackable { false }
    active { true }
    start_date { Time.current - 1.day }
    end_date { Time.current + 1.year }
    discount { Faker::Commerce.price }
  end
end
