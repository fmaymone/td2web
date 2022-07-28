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

  ### Named Entitlements
  REGISTER_AS_FACILITATOR = 'register-facilitator'
  CREATE_ORGANIZATION = 'create-organization'
  CREATE_DIAGNOSTIC_TDA = 'create-diagnostic-tda'
  CREATE_DIAGNOSTIC_TLV = 'create-diagnostic-tlv'
  CREATE_DIAGNOSTIC_T360 = 'create-diagnostic-t360'
  CREATE_DIAGNOSTIC_ORG = 'create-diagnostic-org'
  CREATE_DIAGNOSTIC_L360 = 'create-diagnostic-l360'
  CREATE_DIAGNOSTIC_FT = 'create-diagnostic-ft'
  CREATE_DIAGNOSTIC_ANY = 'create-diagnostic-any'
  GENERATE_REPORT_STANDARD = 'generate-report-standard'
  GENERATE_REPORT_COMPARISON = 'generate-report-comparison'
  GENERATE_REPORT_SEGMENTED = 'generate-report-segmented'
  CASE_STUDY = 'generate-case-study'

  ### Concerns
  include Seeds::Seedable

  ### Validations
  validates :role_id, presence: true
  validates :reference, presence: true, inclusion: AppContext.list
  validates :slug, presence: true, uniqueness: true

  ### Scopes
  scope :active, -> { where(active: true) }
  scope :account, -> { where(account: true) }
  scope :for_role, ->(role) { where(active: true, account: true, role:) }
  scope :for_reference, ->(reference) { where(active: true, reference:) }

  ### Associations
  belongs_to :role
  has_many :grants, dependent: :destroy

  ### Class Methods

  ### Instance Methods
end
