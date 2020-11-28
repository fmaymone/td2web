# frozen_string_literal: true

# == Schema Information
#
# Table name: participants
#
#  id                 :uuid             not null, primary key
#  team_diagnostic_id :uuid             not null
#  state              :string           default("approved"), not null
#  email              :string           not null
#  phone              :string
#  title              :string
#  first_name         :string           not null
#  last_name          :string           not null
#  locale             :string           not null
#  timezone           :string           not null
#  notes              :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class Participant < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %i[email phone title first_name last_name locale timezone notes].freeze
  PARTICIPATING_STATES = %i[approved active completed].freeze

  ### Concerns
  include Participants::StateMachine

  ### Validations
  validates :state, presence: true
  validates :email, presence: true, uniqueness: { scope: :team_diagnostic_id }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :locale, presence: true
  validates :timezone, presence: true
  validate :team_diagnostic_is_active

  ### Scopes
  scope :participating, -> { where(state: PARTICIPATING_STATES) }

  ### Associations
  belongs_to :team_diagnostic

  ### Class Methods

  ### Instance Methods

  def full_name
    [title, first_name, last_name].join(' ')
  end

  private

  def team_diagnostic_is_active
    team_diagnostic&.setup? || team_diagnostic&.deployed?
  end
end
