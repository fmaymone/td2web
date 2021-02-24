# frozen_string_literal: true

# == Schema Information
#
# Table name: diagnostic_responses
#
#  id                          :uuid             not null, primary key
#  diagnostic_survey_id        :uuid             not null
#  team_diagnostic_question_id :uuid             not null
#  response                    :text             not null
#  locale                      :string           not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
class DiagnosticResponse < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %i[team_diagnostic_question_id response].freeze

  ### Associations
  belongs_to :diagnostic_survey
  belongs_to :team_diagnostic_question

  ### Validations
  validates :response, presence: true
  validates :team_diagnostic_question_id, presence: true, uniqueness: { scope: %i[diagnostic_survey_id locale] }
  validate :survey_is_active

  ### Scopes
  scope :rating, -> { includes(:team_diagnostic_question).where(team_diagnostic_questions: { question_type: TeamDiagnosticQuestion::RATING_TYPE }) }
  scope :open_ended, -> { includes(:team_diagnostic_question).where(team_diagnostic_questions: { question_type: TeamDiagnosticQuestion::OPEN_ENDED_TYPE }) }

  private

  def survey_is_active
    errors.add(:response, 'cannot be created or modified for an inactive survey') unless diagnostic_survey.active?
  end
end
