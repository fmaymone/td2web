# frozen_string_literal: true

# Grant Policy
class GrantPolicy < ApplicationPolicy
  # Grant Policy Scope
  class Scope < Scope
    def resolve
      skope = scope
      case user
      when ->(u) { u.admin? }
        skope.includes(:user).where(users: { tenant_id: user.tenant_id })
      when ->(u) { u.staff? }
        skope.includes(:user).where(users: { tenant_id: user.tenant_id })
      else
        skope.where('1=0')
      end
    end
  end

  def index?
    # admin? || staff?
    false
  end

  def new?
    admin? || staff?
  end

  def create?
    admin? || staff?
  end

  def show?
    # admin? || staff?
    false
  end

  def edit?
    admin? || staff?
  end

  def update?
    admin? || staff?
  end

  def destroy?
    admin? || staff?
  end

  def allowed_params
    grant_params = Grant::ALLOWED_PARAMS.dup

    case user
    when ->(u) { u.admin? }
      # NOOP
    when ->(u) { u.staff? }
      # NOOP
    else
      grant_params = []
    end

    grant_params
  end
end
