# frozen_string_literal: true

# == Schema Information
#
# Table name: team_diagnostic_questions
#
#  id                 :uuid             not null, primary key
#  slug               :string           default("OEQ"), not null
#  team_diagnostic_id :uuid
#  body               :string           not null
#  body_positive      :string
#  category           :integer          default("NoCategory"), not null
#  question_type      :integer          default("Open-Ended"), not null
#  factor             :integer          default("NoFactor"), not null
#  matrix             :integer          default(0), not null
#  negative           :boolean          default(FALSE)
#  active             :boolean          default(TRUE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  locale             :string           default("en")
#
class TeamDiagnosticQuestion < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %i[slug body locale].freeze
  DEFAULT_FACTORS = DiagnosticQuestion::DEFAULT_FACTORS
  DEFAULT_CATEGORIES = DiagnosticQuestion::DEFAULT_CATEGORIES
  RATING_TYPE = DiagnosticQuestion::RATING_TYPE
  OPEN_ENDED_TYPE = DiagnosticQuestion::OPEN_ENDED_TYPE
  DEFAULT_TYPES = [RATING_TYPE, OPEN_ENDED_TYPE].freeze
  NOFACTOR = DiagnosticQuestion::NOFACTOR
  NOCATEGORY = DiagnosticQuestion::NOCATEGORY

  ### Enumerables
  enum factor: ['NoFactor'] + DEFAULT_FACTORS
  enum category: ['NoCategory'] + DEFAULT_CATEGORIES
  enum question_type: DEFAULT_TYPES

  ### Concerns
  # None

  ### Validations
  validates :slug, presence: true
  validates :body, presence: true, uniqueness: { scope: %i[team_diagnostic_id locale] }
  validates :category, presence: true
  validates :question_type, presence: true
  validates :factor, presence: true
  validates :matrix, presence: true
  validate :created_before_team_diagnostic_answered

  ### Callbacks

  ### Scopes
  scope :rating, -> { where(question_type: RATING_TYPE) }
  scope :open_ended, -> { where(question_type: OPEN_ENDED_TYPE) }

  ### Associations
  belongs_to :team_diagnostic
  has_one :user, through: :team_diagnostic

  ### Class Methods

  def self.from_diagnostic_question(question, team_diagnostic: nil, locale: nil, all_locales: false)
    locales = if all_locales && team_diagnostic.present?
                team_diagnostic.all_locales
              else
                [locale || team_diagnostic&.locale || 'en']
              end
    locales.map do |l|
      body = begin
        ApplicationTranslation.where(locale: l, key: question.body).first.value
      rescue StandardError
        question.body || 'PLACEHOLDER'
      end
      body_positive = begin
        question.body_positive.present? ? ApplicationTranslation.where(locale: l, key: question.body_positive).first.value : nil
      rescue StandardError
        question.body_positive || 'PLACEHOLDER'
      end
      TeamDiagnosticQuestion.new(
        team_diagnostic: team_diagnostic,
        slug: question.slug,
        body: body,
        body_positive: body_positive,
        category: question.category,
        question_type: question.question_type,
        factor: question.factor,
        matrix: question.matrix,
        locale: l
      )
    end
  end

  ### Instance Methods

  def event_description
    matrix.zero? ? '' : matrix
  end

  def translations
    ApplicationTranslation.where(key: [body, body_positive])
  end

  def open_ended?
    question_type == OPEN_ENDED_TYPE
  end

  def rating?
    question_type == RATING_TYPE
  end

  private

  def created_before_team_diagnostic_answered
    # errors.add(:team_diagnostic_id, 'is deployed'.t) if team_diagnostic.deployed? && _TODOany_questions_answered?
    # TODO validate that no participant has started the diagnostic
    true
  end
end
