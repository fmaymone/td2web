# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  tenant_id              :uuid             not null
#  role_id                :uuid             not null
#  locale                 :string           default("en"), not null
#  timezone               :string           default("Pacific Time (US & Canada)"), not null
#  username               :string           not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class User < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %w[username email locale timezone password password_confirmation].freeze

  ### Concerns and Extensions
  include Users::Devise
  include Users::Roles
  include Users::Profiles
  include Users::Organizations

  ### Associations
  belongs_to :tenant
  has_many :grants, dependent: :destroy
  has_many :team_diagnostics
  has_many :coupons, as: :owner, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :invoices, dependent: :destroy

  ### Attributes

  ### Validations
  validates :locale, presence: true
  validates :timezone, presence: true
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  ### Callbacks

  ### Scopes

  ### Class Methods
  def self.find_for_database_authentication(warden_condition)
    conditions = warden_condition.dup
    login = conditions.delete(:login)
    where(conditions).where(['lower(username) = :value OR lower(email) = :value', { value: login.strip.downcase }]).first
  end

  ### Instance Methods

  def locked?
    locked_at.present?
  end

  def confirmed?
    confirmed_at.present?
  end
end
