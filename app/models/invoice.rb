# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id          :uuid             not null, primary key
#  order_id    :uuid             not null
#  user_id     :uuid             not null
#  remoteid    :string
#  subtotal    :decimal(, )      default(0.0), not null
#  tax         :decimal(, )      default(0.0), not null
#  total       :decimal(, )      default(0.0), not null
#  accepted_at :datetime
#  paid_at     :datetime
#  state       :string           default("pending"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Invoice < ApplicationRecord
  include Invoices::StateMachine

  ### Associations
  belongs_to :order
  belongs_to :user

  ### Validations
  validates :subtotal, presence: true, numericality: { greater_than_or_equal_to: 0.0 }
  validates :tax, presence: true, numericality: { greater_than_or_equal_to: 0.0 }
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0.0 }
  validates :state, presence: true

  def submit
    # TODO: submit invoice to accounting
    accept!
    self
  end

  def allow_complete_order?
    # paid?
  end
end
