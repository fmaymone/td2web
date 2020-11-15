# frozen_string_literal: true

# == Schema Information
#
# Table name: diagnostics
#
#  id          :uuid             not null, primary key
#  slug        :string           not null
#  name        :string           not null
#  description :text             not null
#  active      :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Diagnostic < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %i[slug name description active].freeze
  TDA_SLUG = 'TDA'
  TLV_SLUG = 'TLV'
  T360_SLUG = 'T360'
  ORG_SLUG = 'ORG'

  ### Concerns
  include Seeds::Seedable

  ### Validations
  validates :slug, presence: true
  validates :name, presence: true
  validates :description, presence: true

  ### Scopes
  scope :active, -> { where(active: true) }

  ### Associations

  ### Class Methods

  ### Instance Methods
end
