# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id             :uuid             not null, primary key
#  orderid        :string           not null
#  user_id        :bigint
#  orderable_id   :uuid             not null
#  orderable_type :string           not null
#  subtotal       :decimal(, )      default(0.0), not null
#  tax            :decimal(, )      default(0.0), not null
#  total          :decimal(, )      default(0.0), not null
#  submitted_at   :datetime
#  payment_method :integer          default("invoice"), not null
#  state          :string           default("pending"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
FactoryBot.define do
  factory :order do
    association :user
    association :orderable
  end
end
