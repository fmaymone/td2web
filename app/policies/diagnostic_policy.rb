# frozen_string_literal: true

# Diagnostic Access Policy
class DiagnosticPolicy < ApplicationPolicy
  # Diagnostic Policy Scope
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
    false
  end

  def allowed_params
    permitted_params = Diagnostic::ALLOWED_PARAMS
    case user
    when ->(u) { u.admin? }
      # NOOP
    else
      permitted_params = []
    end
    permitted_params
  end
end
