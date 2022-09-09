# frozen_string_literal: true

# == Schema Information
#
# Table name: user_profiles
#
#  id           :uuid             not null, primary key
#  user_id      :uuid
#  prefix       :string           default("")
#  first_name   :string           default("")
#  middle_name  :string           default("")
#  last_name    :string
#  suffix       :string           default("")
#  pronoun      :string           default("they")
#  country      :string
#  company      :string
#  department   :string
#  title        :string
#  ux_version   :integer          default(0)
#  consent      :jsonb
#  staff_notes  :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  phone_number :string           not null
#  invoiceable  :boolean          default(TRUE), not null
#
class UserProfile < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %i[prefix first_name middle_name last_name suffix pronoun country company department title phone_number].freeze

  ### Concerns and Extensions
  include UserProfiles::Consent

  ### Associations
  belongs_to :user

  ### Validations
  validates :last_name, presence: true
  validates :country, presence: true
  validates :phone_number, presence: true

  ### Callbacks

  ### Scopes

  ### Class Methods

  ### Instance Methods

  def country_name
    GlobalizeCountry.where(code: country).first&.english_name
  end
end
