# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
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
class Organization < ApplicationRecord
  ### Concerns
  audited

  ### Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :domain, presence: true, uniqueness: true

  ### Scopes
  scope :active, -> { where(active: true) }

  ### Class Methods
  def self.default_org
    Organization.active.where(slug: 'default').first
  end

  ### Instance Methods
end
