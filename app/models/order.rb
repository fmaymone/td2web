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
class Order < ApplicationRecord
  ### Constants

  ### Enumerables
  enum payment_method: [:invoice]

  ### Associations
  belongs_to :user
  belongs_to :orderable, polymorphic: true
  has_many :order_items, dependent: :destroy
  has_many :order_discounts, dependent: :destroy

  ### Validations
  validates :orderid, presence: true, uniqueness: true
  validates :subtotal, presence: true, numericality: { greater_than_or_equal_to: 0.0 }
  validates :tax, presence: true, numericality: { greater_than_or_equal_to: 0.0 }
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0.0 }
  validates :payment_method, presence: true
  validates :state, presence: true

  ### Callbacks
  before_validation :generate_orderid, on: :create

  def items_total
    order_items.sum(:total)
  end

  def calculate_total
    self.subtotal = items_total
    self.tax = 0.0 # TODO: tax definitions???
    self.total = (subtotal * (1 + tax)).round(2)
    save
  end

  def submit_invoice
    # TODO

    calculate_total
    return false unless valid?

    create_invoice
  end

  def create_invoice
    # Generate Invoice
    # Post invoice to accounting
    true
  end

  private

  def generate_orderid
    self.orderid ||= SecureRandom.alphanumeric(10).upcase
  end
end
