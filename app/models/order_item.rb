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
class OrderItem < ApplicationRecord
  ### Associations
  belongs_to :order
  belongs_to :product, optional: true
  has_many :order_discounts, dependent: :destroy

  ### Validations
  validates :description, presence: true
  validates :index, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: :order_id }, if: -> { product_id.present? }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0.0 }

  ### Callbacks
  before_validation :generate_index, on: :create

  private

  def generate_index
    last_index = order&.order_items&.pluck(:index)&.max || 0
    self.index = last_index + 1
  end
end
