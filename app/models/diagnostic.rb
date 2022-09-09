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
  LEAD_360_SLUG = 'L360'
  FAMILY_TRIBES_SLUG = 'FT'
  MAXIMUM_PARTICIPANTS = 1000

  ### Concerns
  include Seeds::Seedable

  ### Validations
  validates :slug, presence: true
  validates :name, presence: true
  validates :description, presence: true

  ### Scopes
  scope :active, -> { where(active: true) }

  ### Associations
  has_many :diagnostic_questions, dependent: :destroy
  has_many :report_templates

  ### Class Methods

  ### Instance Methods

  def minimum_participants
    case slug
    when TLV_SLUG, LEAD_360_SLUG
      1
    else
      2
    end
  end

  def maximum_participants
    case slug
    when TLV_SLUG, LEAD_360_SLUG
      1
    else
      MAXIMUM_PARTICIPANTS
    end
  end

  def report_template(version: nil)
    conditions = { state: 'published' }
    conditions.merge!({ version: }) if version
    report_templates.where(conditions).order(version: :desc).first
  end

  def product
    case slug
    when TDA_SLUG
      Product.where(slug: Product::TDA_REPORT).first
    when TLV_SLUG
      Product.where(slug: Product::TLV_REPORT).first
    when T360_SLUG
      Product.where(slug: Product::T360_REPORT).first
    when ORG_SLUG
      Product.where(slug: Product::ORG_REPORT).first
    end
  end
end
