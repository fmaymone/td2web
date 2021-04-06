# frozen_string_literal: true

# TeamDiagnosticQuestion Policy
class TeamDiagnosticQuestionPolicy < ApplicationPolicy
  # TeamDiagnostic Policy Scope
  class Scope < Scope
    def resolve
      skope = scope.includes(:user)
      case user
      when ->(u) { u.admin? }
        skope.where(users: { tenant_id: user.tenant_id })
      when ->(u) { u.staff? }
        skope.where(users: { tenant_id: user.tenant_id })
      when ->(u) { u.facilitator? }
        skope.where(users: { id: user.id })
      else
        skope.where('1=0')
      end
    end
  end

  def index?
    admin? || staff? || facilitator?
  end

  def new?
    admin? || staff? || facilitator?
  end

  def create?
    new?
  end

  def show?
    admin? || staff? || owner?
  end

  def edit?
    (admin? || staff? || owner?) && team_diagnostic_policy.modify_questions?
  end

  def update?
    edit?
  end

  def destroy?
    update? && team_diagnostic_policy.modify_questions?
  end

  def allowed_params
    TeamDiagnosticQuestion::ALLOWED_PARAMS
  end

  def team_diagnostic_policy
    @team_diagnostic_policy ||= TeamDiagnosticPolicy.new(user, record&.team_diagnostic)
  end
end
