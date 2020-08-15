# frozen_string_literal: true

# Tenant Policy
class TenantPolicy < ApplicationPolicy
  # Tenant Policy Scope
  class Scope < Scope
    def resolve
      skope = scope
      case user
      when ->(u) { u.admin? }
        skope
      else
        skope.where('1=0')
      end
    end
  end

  def index?
    user.admin?
  end

  def new?
    user.admin?
  end

  def create?
    new?
  end

  def show?
    index?
  end

  def edit?
    user.admin?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  def allowed_params
    tenant_params = Tenant::ALLOWED_PARAMS.dup

    case user
    when ->(u) { u.admin? }
      # noop
    else
      tenant_params = []
    end

    tenant_params
  end
end
