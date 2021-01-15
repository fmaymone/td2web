# frozen_string_literal: true

# == Schema Information
#
# Table name: diagnostic_surveys
#
#  id                 :uuid             not null, primary key
#  team_diagnostic_id :uuid             not null
#  participant_id     :uuid             not null
#  state              :string           default("pending"), not null
#  locale             :string           default("en"), not null
#  notes              :text
#  last_activity_at   :datetime
#  delivered_at       :datetime
#  started_at         :datetime
#  completed_at       :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class DiagnosticSurvey < ApplicationRecord
  ### Constants

  ### Concerns
  include DiagnosticSurveys::StateMachine
  include DiagnosticSurveys::Messaging

  ### Validations
  validates :locale, presence: true
  validates :state, presence: true,
                    inclusion: DiagnosticSurvey.aasm.states.map(&:name).map(&:to_s)

  ### Scopes

  ### Associations
  belongs_to :participant
  belongs_to :team_diagnostic
  has_many :questions, through: :team_diagnostic, class_name: 'TeamDiagnosticQuestion'
end
