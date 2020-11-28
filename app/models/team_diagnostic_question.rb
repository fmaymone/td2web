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
#
class TeamDiagnosticQuestion < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %i[body].freeze
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
  validates :body, presence: true, uniqueness: { scope: :team_diagnostic_id }
  validates :category, presence: true
  validates :question_type, presence: true
  validates :factor, presence: true
  validates :matrix, presence: true
  validate :created_before_team_diagnostic_deployment

  ### Callbacks
  after_create :create_default_translations

  ### Scopes
  scope :rating, -> { where(question_type: RATING_TYPE) }
  scope :open_ended, -> { where(question_type: OPEN_ENDED_TYPE) }

  ### Associations
  belongs_to :team_diagnostic
  has_one :user, through: :team_diagnostic

  ### Class Methods

  def self.from_diagnostic_question(question, team_diagnostic: nil)
    TeamDiagnosticQuestion.new(
      team_diagnostic: team_diagnostic,
      slug: question.slug,
      body: question.body,
      body_positive: question.body_positive,
      category: question.category,
      question_type: question.question_type,
      factor: question.factor,
      matrix: question.matrix
    )
  end

  ### Instance Methods

  def translations
    ApplicationTranslation.where(key: [body, body_positive])
  end

  private

  def create_default_translations
    default_locale = team_diagnostic.locale
    attrs = { locale: default_locale, key: body, value: body }
    ApplicationTranslation.create(attrs) unless ApplicationTranslation.where(locale: default_locale, key: attrs[:key]).any?
  end

  def created_before_team_diagnostic_deployment
    errors.add(:team_diagnostic_id, 'is deployed'.t) if team_diagnostic.deployed?
  end
end
