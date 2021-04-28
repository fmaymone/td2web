# frozen_string_literal: true

# == Schema Information
#
# Table name: team_diagnostic_letters
#
#  id                 :uuid             not null, primary key
#  team_diagnostic_id :uuid
#  letter_type        :integer
#  locale             :string           default("en")
#  subject            :string
#  body               :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class TeamDiagnosticLetter < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %i[letter_type locale subject body].freeze

  DEFAULT_COVER_LETTER = 'template-teamdiagnostic-cover-letter'
  DEFAULT_REMINDER_LETTER = 'template-teamdiagnostic-reminder-letter'
  DEFAULT_CANCELLATION_LETTER = 'template-teamdiagnostic-cancellation-letter'

  COVER_TYPE = 'cover'
  REMINDER_TYPE = 'reminder'
  CANCELLATION_TYPE = 'cancellation'
  LETTER_TYPE_DEF = {
    cover: COVER_TYPE,
    reminder: REMINDER_TYPE,
    cancellation: CANCELLATION_TYPE
  }.freeze
  LETTER_TYPES = [COVER_TYPE, REMINDER_TYPE, CANCELLATION_TYPE].freeze

  ### Enumerables
  enum letter_type: LETTER_TYPES

  ### Concerns

  ### Validations
  validates :subject, presence: true
  validates :body, presence: true
  validates :locale, presence: true
  validates :letter_type, inclusion: LETTER_TYPES, presence: true, uniqueness: { scope: %i[locale team_diagnostic_id] }

  ### Scopes
  scope :typed, ->(t) { where(letter_type: LETTER_TYPE_DEF[t.to_sym]) }

  ### Associations
  belongs_to :team_diagnostic

  ### Class Methods

  def self.default_letter(type:, locale:, team_diagnostic: nil)
    send("default_#{type}_letter", locale: locale, team_diagnostic: team_diagnostic)
  end

  def self.default_cover_letter(locale:, team_diagnostic: nil)
    TeamDiagnosticLetter.new(
      team_diagnostic: team_diagnostic,
      letter_type: 'cover',
      locale: locale,
      subject: ApplicationTranslation.where(key: "#{DEFAULT_COVER_LETTER}-subject", locale: locale).first&.value || '--',
      body: ApplicationTranslation.where(key: DEFAULT_COVER_LETTER, locale: locale).first&.value || '--'
    )
  end

  def self.default_cover_letter_subject(locale:)
    ApplicationTranslation.where(key: "#{DEFAULT_COVER_LETTER}-subject", locale: locale).first&.value || '--'
  end

  def self.default_reminder_letter(locale:, team_diagnostic: nil)
    TeamDiagnosticLetter.new(
      team_diagnostic: team_diagnostic,
      letter_type: 'reminder',
      locale: locale,
      subject: default_reminder_letter_subject(locale: locale),
      body: ApplicationTranslation.where(key: DEFAULT_REMINDER_LETTER, locale: locale).first&.value || '--'
    )
  end

  def self.default_reminder_letter_subject(locale:)
    ApplicationTranslation.where(key: "#{DEFAULT_REMINDER_LETTER}-subject", locale: locale).first&.value || '--'
  end

  def self.default_cancellation_letter(locale:, team_diagnostic: nil)
    TeamDiagnosticLetter.new(
      team_diagnostic: team_diagnostic,
      letter_type: 'cancellation',
      locale: locale,
      subject: default_cancellation_letter_subject(locale: locale),
      body: ApplicationTranslation.where(key: DEFAULT_CANCELLATION_LETTER, locale: locale).first&.value || '--'
    )
  end

  def self.default_cancellation_letter_subject(locale:)
    ApplicationTranslation.where(key: "#{DEFAULT_CANCELLATION_LETTER}-subject", locale: locale).first&.value || '--'
  end

  ### Instance Methods
end
