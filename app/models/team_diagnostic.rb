# frozen_string_literal: true

# == Schema Information
#
# Table name: team_diagnostics
#
#  id                  :uuid             not null, primary key
#  organization_id     :uuid             not null
#  user_id             :uuid             not null
#  team_diagnostic_id  :uuid
#  diagnostic_id       :uuid             not null
#  state               :string           default("setup"), not null
#  locale              :string           default("en"), not null
#  timezone            :string           not null
#  name                :string           not null
#  description         :text             not null
#  situation           :text
#  functional_area     :string           not null
#  team_type           :string           not null
#  show_members        :boolean          default(TRUE), not null
#  contact_phone       :string           not null
#  contact_email       :string           not null
#  alternate_email     :string
#  cover_letter        :text             not null
#  reminder_letter     :text             not null
#  cancellation_letter :text             not null
#  due_at              :datetime         not null
#  completed_at        :datetime
#  deployed_at         :datetime
#  auto_deploy_at      :datetime
#  reminder_at         :datetime
#  reminder_sent_at    :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  wizard              :integer          default(1), not null
#
class TeamDiagnostic < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %w[organization_id team_diagnostic_id diagnostic_id locale timezone name description situation functional_area team_type show_members contact_phone contact_email alternate_email cover_letter reminder_letter cancellation_letter due_at auto_deploy_at reminder_at logo _destroy_logo].freeze
  FUNCTIONAL_AREAS = ['IT', 'Senior Management', 'Marketing', 'Non-Profit Board', 'Other'].freeze
  TEAM_TYPES = %w[Executive Cross-Functional Virtual Intact Project Other].freeze

  ### Concerns
  include TeamDiagnostics::StateMachine
  include TeamDiagnostics::Wizard
  include TeamDiagnostics::Logo
  include TeamDiagnostics::ParticipantImports

  ### Validations
  validates :alternate_email, presence: true
  validates :cancellation_letter, presence: true
  validates :contact_email, presence: true
  validates :contact_phone, presence: true
  validates :cover_letter, presence: true
  validates :description, presence: true
  validates :due_at, presence: true
  validates :functional_area, presence: true
  validates :locale, presence: true
  validates :name, presence: true
  validates :reminder_letter, presence: true
  validates :state, presence: true
  validates :team_type, presence: true
  validates :timezone, presence: true
  validates :organization_id, inclusion: { in: ->(record) { record.user.organizations.pluck(:id) } }
  validate :due_at_is_in_the_future
  validate :reminder_at_is_before_due_date

  ### Scopes

  ### Associations
  belongs_to :user
  belongs_to :organization
  belongs_to :diagnostic
  belongs_to :reference_diagnostic, class_name: 'TeamDiagnostic', foreign_key: 'team_diagnostic_id', required: false
  has_many :participants, dependent: :destroy
  has_many :questions, class_name: 'TeamDiagnosticQuestion', dependent: :destroy

  ### Class Methods

  ### Instance Methods

  def ready_for_deploy?
    setup? && sufficient_participants?
  end

  def sufficient_participants?
    participants.participating.count >= diagnostic.minimum_participants
  end

  def all_participants_are_disqualified?
    participants.participating.none? && participants.any?
  end

  def perform_deployment
    return false unless assign_questions
    return false unless activate_participants

    self.deployed_at = Time.now
    save!
  end

  private

  def assign_questions
    return false unless diagnostic.present?
    return false unless setup? || deployed?

    # TODO: log error event

    transaction do
      # TODO
      # Delete Diagnostic questions if no one has answered any questions
      # questions.destroy_all unless diagnostic_responses.any?
      questions.destroy_all
      diagnostic.diagnostic_questions.active.each do |question|
        TeamDiagnosticQuestion.from_diagnostic_question(question, team_diagnostic: self).save!
      end
    end
    true
  rescue StandardError
    false
  end

  def activate_participants
    transaction do
      participants.approved.each do |participant|
        next unless participant.may_activate?

        participant.activate!
        # else
        # TODO
        # Log the failure to activate the participant
      end
    end
    true
    # rescue StandardError
    # false
  end

  def due_at_is_in_the_future
    (due_at.present? && due_at > Time.now) or
      errors.add(:due_date, 'must be in the future')
  end

  def reminder_at_is_before_due_date
    (reminder_at.present? && reminder_at < due_at) or
      errors.add(:reminder_at, 'must be before the due date')
  end
end
