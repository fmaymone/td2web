# frozen_string_literal: true

# Policy for Managing Entitlements
class EntitlementPolicy < ApplicationPolicy
  # Entitlement Scope resolver
  class Scope < Scope
    def resolve
      skope = scope
      case user
      when ->(u) { u.admin? }
        skope
      end
      skope
    end
  end

  def index?
    admin?
  end

  def show?
    admin?
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
    admin?
  end

  def destroy?
    record.grants.none? && edit?
  end

  def allowed_params
    entitlement_params = Entitlement::ALLOWED_PARAMS
    case user
    when ->(u) { u.admin? }
      # NOOP
    else
      entitlement_params = []
    end
    entitlement_params
  end
end
