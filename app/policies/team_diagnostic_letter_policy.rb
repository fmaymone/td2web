# frozen_string_literal: true

# TeamDiagnosticLetter Policy
class TeamDiagnosticLetterPolicy < ApplicationPolicy
  # TeamDiagnosticLetter Policy Scope
  class Scope < Scope
    def resolve
      skope = scope.includes({ team_diagnostic: :user })
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
    admin? || staff? || owner?
  end

  def update?
    edit?
  end

  def destroy?
    update?
  end

  def allowed_params
    TeamDiagnosticLetter::ALLOWED_PARAMS
  end
end
