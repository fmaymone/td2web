# frozen_string_literal: true

# Participant
class ParticipantPolicy < ApplicationPolicy
  # Participant Policy Scope
  class Scope < Scope
    def resolve
      skope = scope.includes(team_diagnostic: :user)
      case user
      when ->(u) { u.admin? }
        skope.where(users: { tenant_id: user.tenant_id })
      when ->(u) { u.staff? }
        skope.where(users: { tenant_id: user.tenant_id })
      when ->(u) { u.facilitator? }
        skope.where(team_diagnostics: { user_id: user.id })
      else
        skope.where('1=0')
      end
    end
  end

  def owner?
    record&.team_diagnostic&.user == user
  end

  def index?
    admin? || staff? || facilitator?
  end

  def new?
    (admin? || staff? || facilitator?)
  end

  def create?
    new?
  end

  def show?
    admin? || staff? || owner?
  end

  def edit?
    (record.approved? || record.active?) &&
      (admin? || staff? || owner?) &&
      TeamDiagnosticPolicy.new(user, record.team_diagnostic).modify_participants?
  end

  def update?
    edit?
  end

  def destroy?
    (admin? || staff? || owner?) &&
      team_diagnostic_policy.modify_participants?
  end

  def disqualify?
    !record.disqualified? &&
      (admin? || staff? || owner?) &&
      %w[setup deployed completed cancelled].include?(record.team_diagnostic.state)
  end

  def restore?
    record.disqualified? &&
      (admin? || staff? || owner?) &&
      team_diagnostic_policy.modify_participants?
  end

  def activate?
    edit? && record.activation_permitted? && !record.active?
  end

  def resend_invitation?
    edit? && record.active?
  end

  def allowed_params
    Participant::ALLOWED_PARAMS
  end

  def team_diagnostic_policy
    @team_diagnostic_policy ||= TeamDiagnosticPolicy.new(user, record&.team_diagnostic)
  end
end
