# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id          :uuid             not null, primary key
#  tenant_id   :uuid             not null
#  name        :string           not null
#  description :text
#  url         :string           not null
#  industry    :integer          not null
#  revenue     :integer          not null
#  locale      :string           default("en"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Organization < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %i[name description url industry revenue locale].freeze
  REVENUE_NONPROFIT = 'Non Profit Organization'

  ### Concerns

  ### Enums
  enum industry: ['Agriculture', 'Apparel', 'Banking', 'Biotechnology', 'Chemicals', 'Communication', 'Construction', 'Consulting', 'Education', 'Electronics', 'Energy', 'Engineering', 'Entertainment', 'Environmental', 'Finance', 'Food and Beverage', 'Government', 'Health Care Facilities', 'Hospitality', 'Insurance', 'Manufacturing', 'Media / Publishing', 'Medical / Pharmaceutical', 'Not for Profit / NGO', 'Recreation', 'Retail', 'Shipping', 'Technology / Software', 'Telecommunications', 'Transportation', 'Utilities', 'Other']
  enum revenue: [REVENUE_NONPROFIT, 'For Profit Organization under US$1 million', 'For Profit Organization US$1-10 million', 'For Profit Organization US$10-25 million', 'For Profit Organization US$25-50 million', 'For Profit Organization US$50-100 million', 'For Profit Organization over US$100 million']

  ### Validations
  validates :name, presence: true
  validates :url, presence: true
  validates :industry, presence: true, inclusion: Organization.industries.keys
  validates :revenue, presence: true, inclusion: Organization.revenues.keys
  validates :locale, presence: true

  ### Callbacks

  ### Scopes

  ### Associations
  belongs_to :tenant
  has_many :organization_users, dependent: :destroy
  has_many :members, through: :organization_users, class_name: 'User', source: :user
  has_many :team_diagnostics
  has_many :coupons, as: :owner, dependent: :destroy
  has_many :orders, through: :team_diagnostics

  ### Class Methods

  ### Instance Methods

  def admins
    organization_users.admins
  end

  def admin?(user)
    admins.where(user_id: user.id).any?
  end

  def nonprofit?
    revenue == REVENUE_NONPROFIT
  end
end
