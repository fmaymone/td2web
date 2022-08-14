# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id                 :uuid             not null, primary key
#  product_type       :integer          default("standalone"), not null
#  slug               :string           not null
#  name               :string           not null
#  description        :text
#  price              :decimal(, )      default(0.0), not null
#  volume_pricing     :jsonb            not null
#  entitlement_detail :jsonb            not null
#  active             :boolean          default(TRUE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class Product < ApplicationRecord
  ### Constants
  TLV_REPORT = 'tlv-report-standard'
  TDA_REPORT = 'tda-report-standard'
  T360_REPORT = 't360-report-standard'
  ORG_REPORT = 'org-report-standard'

  ### Concerns
  include Seeds::Seedable

  ### Enumerables
  enum product_type: %i[standalone addon]

  ### Validations
  validates :active, presence: true
  validates :name, presence: true
  validates :price, presence: true
  validates :product_type, presence: true
  validates :slug, presence: true
end
