# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id                 :uuid             not null, primary key
#  product_type       :integer          default("standalone"), not null
#  slug               :string           not null
#  name               :string           not null
#  description        :text
#  price              :decimal(, )      default(0.0), not null
#  volume_pricing     :jsonb            not null
#  entitlement_detail :jsonb            not null
#  active             :boolean          default(TRUE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
FactoryBot.define do
  factory :product do
    slug { Faker::Lorem.alphanumeric }
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
    price { Faker::Commerce.price }
    volume_pricing { {} }
    entitlement_detail { {} }
  end
end
