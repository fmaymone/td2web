# frozen_string_literal: true

# == Schema Information
#
# Table name: entitlements
#
#  id          :uuid             not null, primary key
#  account     :boolean          default(TRUE), not null
#  active      :boolean          default(TRUE), not null
#  role_id     :uuid             not null
#  reference   :string           not null
#  slug        :string           not null
#  description :text
#  quota       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Entitlement < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %i[account active role_id reference slug description quota].freeze
  REGISTER_AS_FACILITATOR = 'register-facilitator'

  ### Concerns

  ### Validations
  validates :role_id, presence: true
  validates :reference, presence: true, inclusion: AppContext.list
  validates :slug, presence: true, uniqueness: true

  ### Scopes
  scope :active, -> { where(active: true) }
  scope :account, -> { where(account: true) }
  scope :for_role, ->(role) { where(active: true, account: true, role: role) }
  scope :for_reference, ->(reference) { where(active: true, reference: reference) }

  ### Associations
  belongs_to :role
  has_many :grants, dependent: :destroy

  ### Class Methods

  ### Instance Methods
end
