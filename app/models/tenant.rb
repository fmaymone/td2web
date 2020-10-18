# frozen_string_literal: true

# == Schema Information
#
# Table name: tenants
#
#  id          :uuid             not null, primary key
#  name        :string
#  slug        :string
#  domain      :string
#  description :text
#  active      :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  locale      :string           default("en")
#
class Tenant < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %w[name slug domain description active].freeze

  ### Concerns

  ### Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :domain, presence: true, uniqueness: true

  ### Scopes
  scope :active, -> { where(active: true) }

  ### Associations
  has_many :users
  has_many :invitations
  has_many :organizations

  ### Class Methods
  def self.default_tenant
    Tenant.active.where(slug: 'default').first
  end

  ### Instance Methods
end
