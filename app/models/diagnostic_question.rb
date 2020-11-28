# frozen_string_literal: true

# == Schema Information
#
# Table name: diagnostic_questions
#
#  id            :uuid             not null, primary key
#  slug          :string           not null
#  diagnostic_id :uuid
#  body          :string           not null
#  body_positive :string
#  category      :integer          not null
#  question_type :integer          not null
#  factor        :integer          not null
#  matrix        :integer          not null
#  negative      :boolean          default(FALSE)
#  active        :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class DiagnosticQuestion < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %i[diagnostic_id body body_positive category question_type factor matrix negative active].freeze
  DEFAULT_FACTORS = ['Decision Making', 'Resources', 'Alignment', 'Values Diversity', 'Camaraderie', 'Constructive Interaction', 'Communication', 'Trust', 'Optimism', 'Team Leadership', 'Goals & Strategies', 'Respect', 'Accountability', 'Proactive'].freeze
  DEFAULT_CATEGORIES = %w[Productivity Positivity].freeze
  RATING_TYPE = 'Rating'
  OPEN_ENDED_TYPE = 'Open-Ended'
  DEFAULT_TYPES = [RATING_TYPE, OPEN_ENDED_TYPE].freeze
  NOFACTOR = 'NoFactor'
  NOCATEGORY = 'NoCategory'

  ### Enumerables
  enum factor: ['NoFactor'] + DEFAULT_FACTORS
  enum category: ['NoCategory'] + DEFAULT_CATEGORIES
  enum question_type: DEFAULT_TYPES

  ### Concerns
  include Seeds::Seedable
  include Seeds::SeedableCsv

  ### Validations
  validates :slug, presence: true, uniqueness: true
  validates :body, presence: true
  validates :category, presence: true
  validates :question_type, presence: true
  validates :factor, presence: true
  validates :matrix, presence: true

  ### Callbacks
  before_validation :create_slug, on: :create
  after_create :create_default_translations

  ### Scopes
  scope :active, -> { where(active: true) }
  scope :rating, -> { where(question_type: RATING_TYPE) }
  scope :open_ended, -> { where(question_type: OPEN_ENDED_TYPE) }

  ### Associations
  belongs_to :diagnostic

  ### Class Methods

  ### Instance Methods

  def translations
    ApplicationTranslation.where(key: [body, body_positive])
  end

  private

  def create_default_translations
    attrs = { locale: 'en', key: body, value: body }
    ApplicationTranslation.create(attrs) unless ApplicationTranslation.where(locale: 'en', key: attrs[:key]).any?
    return unless negative

    attrs = { locale: 'en', key: body_positive, value: body_positive }
    ApplicationTranslation.create(attrs) unless ApplicationTranslation.where(locale: 'en', key: attrs[:key]).any?
  end

  def create_slug
    self.slug ||= [diagnostic&.slug, category, question_type, factor, matrix].compact.join('-')
  end
end
