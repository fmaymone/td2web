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
  has_many :diagnostic_surveys, dependent: :destroy

  ### Class Methods

  ### Instance Methods

  def event_description
    full_name
  end

  def needs_attention?
    pending_actions.any?
  end

  def pending_actions
    actions = []
    actions << 'Invalid'.t unless valid?
    actions << 'Please invite this participant'.t if pending_invitation?
    actions
  end

  def pending_invitation?
    !active? && team_diagnostic.deployed?
  end

  def full_name
    [title, first_name, last_name].join(' ')
  end

  def active_survey
    diagnostic_surveys.active.order(created_at: :desc).first
  end

  def create_active_survey
    cancel_surveys
    diagnostic_surveys
      .create(team_diagnostic: team_diagnostic, locale: locale)
      .activate!
  end

  def survey_completed?
    diagnostic_surveys.completed.any?
  end

  def survey_active?
    active_survey.present?
  end

  def cancel_surveys
    diagnostic_surveys.active.each(&:cancel!)
  end

  def team_diagnostic_is_active
    team_diagnostic&.setup? || team_diagnostic&.deployed?
  end

  def send_reminder
    return false unless active_survey.present?

    active_survey.send_reminder_message
  end

  def progress_pct
    if active_survey
      (active_survey.progress * 100.0).round(0)
    else
      0.0
    end
  end
end
