# frozen_string_literal: true

# == Schema Information
#
# Table name: team_diagnostics
#
#  id                 :uuid             not null, primary key
#  organization_id    :uuid             not null
#  user_id            :uuid             not null
#  team_diagnostic_id :uuid
#  diagnostic_id      :uuid             not null
#  state              :string           default("setup"), not null
#  locale             :string           default("en"), not null
#  timezone           :string           not null
#  name               :string           not null
#  description        :text             not null
#  situation          :text
#  functional_area    :string           not null
#  team_type          :string           not null
#  show_members       :boolean          default(TRUE), not null
#  contact_phone      :string           not null
#  contact_email      :string           not null
#  alternate_email    :string
#  due_at             :datetime         not null
#  completed_at       :datetime
#  deployed_at        :datetime
#  auto_deploy_at     :datetime
#  reminder_at        :datetime
#  reminder_sent_at   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  wizard             :integer          default(1), not null
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
  include TeamDiagnostics::Messaging
  include TeamDiagnostics::Letters
  include TeamDiagnostics::Errors

  ### Validations
  validates :alternate_email, presence: true
  validates :contact_email, presence: true
  validates :contact_phone, presence: true
  validates :description, presence: true
  validates :due_at, presence: true
  validates :functional_area, presence: true
  validates :locale, presence: true
  validates :name, presence: true
  validates :state, presence: true, inclusion: TeamDiagnostic.aasm.states.map(&:name).map(&:to_s)
  validates :team_type, presence: true
  validates :timezone, presence: true
  validates :organization_id, inclusion: { in: ->(record) { record.user.organizations.pluck(:id) } }
  validate :due_at_is_in_the_future
  validate :reminder_at_is_before_due_date

  ### Scopes
  scope :pending_deployment, -> { setup.where(arel_table[:auto_deploy_at].lt(Time.now)) }
  scope :pending_reminder, -> { deployed.where(reminder_sent_at: nil).where(arel_table[:reminder_at].lt(Time.now)) }
  scope :pending_completion, -> { deployed.where(arel_table[:due_at].lt(Time.now)) }

  ### Associations
  belongs_to :user
  belongs_to :organization
  belongs_to :diagnostic
  belongs_to :reference_diagnostic, class_name: 'TeamDiagnostic', foreign_key: 'team_diagnostic_id', required: false
  has_many :participants, dependent: :destroy
  has_many :questions, class_name: 'TeamDiagnosticQuestion', dependent: :destroy
  has_many :diagnostic_surveys, dependent: :destroy
  has_many :diagnostic_responses, through: :diagnostic_surveys
  has_many :team_diagnostic_questions, dependent: :destroy
  has_many :system_events, as: :event_source

  attr_accessor :deployment_succeeded

  ### Class Methods

  def self.auto_deploy
    pending_deployment.each do |diagnostic|
      diagnostic.deploy!
    rescue StandardError => e
      SystemEvent.log(event_source: diagnostic, description: 'Automatic deployment failed', severity: :error, debug: e.message)
    end
  end

  def self.auto_complete
    pending_completion.each do |diagnostic|
      diagnostic.complete!
    rescue StandardError => e
      SystemEvent.log(event_source: diagnostic, description: 'Automatic completion failed', severity: :error, debug: e.message)
    end
  end

  ### Instance Methods

  def needs_attention?
    pending_actions.any?
  end

  def pending_actions
    actions = deployment_issues
    actions << 'There are new participants pending activation'.t if participants_pending_activation?
    actions
  end

  def deployment_issues
    errors = []
    errors << 'Information is missing or invalid'.t unless valid?
    errors << 'Please invite more participants'.t unless sufficient_participants?
    errors << 'Please invite fewer participants'.t if excess_participants?
    errors << 'Please create Open Ended Question translations'.t unless sufficient_open_ended_question_translations?
    errors << 'Please create letter translations'.t unless sufficient_letter_translations?
    errors
  end

  def deployment_issues?
    deployment_issues.any?
  end

  # def deployment_overdue?
  # auto_deploy_at < Time.now
  # end

  # def reminder_overdue?
  # reminder_at < Time.now
  # end

  # def days_until_deploy
  # ((auto_deploy_at - Time.now) / 1.day).ceil
  # end

  def all_locales
    ([locale] + participant_locales).sort.uniq
  end

  def participant_locales
    participants.pluck(:locale).sort.uniq
  end

  # def letter_locales
  # team_diagnostic_letters.pluck(:locale).sort.uniq
  # end

  def ready_for_deploy?
    (setup? || cancelled?) && !deployment_issues?
  end

  def sufficient_participants?
    return true unless diagnostic && %w[setup deployed].include?(state)

    participants.participating.count >= diagnostic.minimum_participants
  end

  def excess_participants?
    return true unless diagnostic && %w[setup deployed].include?(state)

    participants.participating.count <= diagnostic.maximum_participants
  end

  def participants_pending_activation?
    return false unless %w[setup deployed].include? state

    participants_pending_activation.any?
  end

  def participants_pending_activation
    return [] unless deployed?

    participants.approved
  end

  def sufficient_open_ended_question_translations?
    return true if team_diagnostic_questions.open_ended.none?

    return false if participant_locales.count.zero? || team_diagnostic_questions.count.zero?

    open_ended_question_locales.empty? ||
      ((participant_locales - open_ended_question_locales == []) &&
        (team_diagnostic_questions.count % participant_locales.count).zero?)
  end

  def open_ended_question_locales
    team_diagnostic_questions.open_ended.pluck(:locale).sort.uniq
  end

  def sufficient_letter_translations?
    missing_letters.empty? && team_diagnostic_letters.where(locale: participant_locales).to_a.none? do |l|
      (l.subject || '').empty? || l.subject == '--'
      (l.body || '').empty? || l.body == '--'
    end
  end

  # def all_participants_are_disqualified?
  # participants.any? && participants.participating.none?
  # end

  def perform_deployment
    diagnostic_responses.each(&:destroy)
    diagnostic_responses.reload

    self.deployment_succeeded = false

    issues = deployment_issues
    raise DeploymentIssueError, issues if issues.any?

    did_assign_questions = assign_questions
    raise QuestionAssignmentError unless did_assign_questions

    self.deployed_at = Time.now
    save
    send_deploy_notification_message
    self.deployment_succeeded = true

    SystemEvent.log(event_source: self, description: 'Deployment was successful', severity: :warn)
  rescue DeploymentIssueError => e
    debug_msg = "Error deploying TeamDiagnostic[#{id}] due to pending actions : #{e.message}]"
    SystemEvent.log(event_source: self, description: 'Failed to deploy', severity: :error, debug: debug_msg)
    false
  rescue QuestionAssignmentError => e
    debug_msg = "Error deploying TeamDiagnostic[#{id}] while assigning questions: #{e.message}]"
    SystemEvent.log(event_source: self, description: 'Failed to deploy', severity: :error, debug: debug_msg)
    false
  end

  def cancel_deployment
    participants.active.each do |participant|
      participant.cancel!
    rescue StandardError
      true
    end
    send_cancel_notification_message
    SystemEvent.log(event_source: self, incidental: nil, description: 'The Diagnostic was cancelled', severity: :warn)
  end

  def completed_surveys
    diagnostic_surveys.completed.count
  end

  def total_surveys
    diagnostic_surveys.pending.count + diagnostic_surveys.active.count
  end

  def auto_respond
    return if Rails.env.production?

    participants.each do |participant|
      diagnostic_survey = participant.active_survey
      svc = DiagnosticSurveyServices::QuestionService.new(diagnostic_survey: diagnostic_survey)
      all_questions = svc.all_questions
      all_questions[0..].each do |q|
        response = rand(1..9)
        svc.answer_question(question: q, response: response)
      end
      svc.diagnostic_survey.complete!
    end
  end

  private

  def assign_questions
    return false unless diagnostic.present?
    return false unless setup? || deployed? || cancelled?

    transaction do
      # Delete default Diagnostic questions if no one has answered any questions
      questions.rating.destroy_all unless diagnostic_responses.any?
      diagnostic.diagnostic_questions.rating.active.each do |question|
        TeamDiagnosticQuestion.from_diagnostic_question(question, team_diagnostic: self).map(&:save!)
      end
    end
    true
  rescue StandardError => e
    debug_msg = e.message
    SystemEvent.log(event_source: self, description: 'Error assigning questions', debug: debug_msg, severity: :debug)
    false
  end

  def activate_participants
    transaction do
      participants.approved.each do |participant|
        participant.activate!
      rescue StandardError => e
        debug_msg = e.message
        SystemEvent.log(event_source: self, incidental: participant, description: 'Error activating participant', debug: debug_msg, severity: :warn)
      end
    end
    participants.reload
    participants.active.any?
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
