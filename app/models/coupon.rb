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
class Coupon < ApplicationRecord
  ### Constants
  NONPROFIT_DISCOUNT = 10
  NONPROFIT_DISCOUNT_DESCRIPTION = 'Nonprofit Organization Discount'

  ### Validations
  validates :discount, presence: true
  validates :start_date, presence: true
  validates :code, presence: true
  validates :description, presence: true
  validates :discount, presence: true, numericality: { greater_than: 0 }

  ### Associations
  belongs_to :owner, polymorphic: true, optional: true
  belongs_to :product, optional: true

  ### Scopes
  scope :active, -> { where(active: true) }
  scope :reuseable, -> { where(reusable: true) }

  def usable?(for_owner: nil, for_product: nil)
    active? &&
      valid_date? &&
      (for_owner.present? ? owner == for_owner : true) &&
      ((for_product.present? && product.present?) ? product == for_product : true) &&
      unused?
  end

  def valid_date?
    (start_date.present? ? start_date < Time.current : true) &&
      (end_date.present? ? end_date > Time.current : true)
  end

  def unused?
    # TODO
    # OrderDiscount.includes(order: { invoice: { state: Invoice::ACTIVE_STATES } })
    # .where(coupon: self, coupons: { reusable: false })
    # .none?
    true
  end
end
