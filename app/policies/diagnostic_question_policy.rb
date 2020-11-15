# frozen_string_literal: true

# DiagnosticQuestion Access Policy
class DiagnosticQuestionPolicy < ApplicationPolicy
  # DiagnosticQuestion Policy Scope
  class Scope < Scope
    def resolve
      skope = scope
      case user
      when ->(u) { u.admin? }
        skope
      when ->(u) { u.staff? }
        skope
      else
        skope.where('1=0')
      end
    end
  end

  def index?
    admin? || staff?
  end

  def show?
    admin? || staff?
  end

  def new?
    admin?
  end

  def create?
    new?
  end

  def edit?
    admin?
  end

  def update?
    edit?
  end

  def destroy?
    admin? && record.translations.empty?
  end

  def allowed_params
    permitted_params = DiagnosticQuestion::ALLOWED_PARAMS
    case user
    when ->(u) { u.admin? }
      permitted_params = DiagnosticQuestion::ALLOWED_PARAMS + [:slug]
    when ->(u) { u.staff? }
      # NOOP
    else
      permitted_params = []
    end
    permitted_params
  end
end
