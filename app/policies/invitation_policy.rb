# frozen_string_literal: true

# Invitation Access Policy
class InvitationPolicy < ApplicationPolicy
  # Invitation Policy Scope
  class Scope < Scope
    def resolve
      skope = scope
      case user
      when ->(u) { u.admin? }
        skope
      when ->(u) { u.staff? }
        skope.where(tenant_id: user.tenant_id)
      else
        skope.where('1=0')
      end
    end
  end

  def index?
    admin? || staff?
  end

  def new?
    admin? || staff?
  end

  def create?
    new?
  end

  def show?
    admin? || staff?
  end

  def edit?
    # admin? || staff?
    false
  end

  def update?
    # edit?
    false
  end

  def destroy?
    record.active? && !record.claimed? && (admin? || staff?)
  end

  def claim?
    true
  end

  def process_claim?
    true
  end

  def allowed_params
    params = EntitlementServices::InvitationCreator::PERMITTED_PARAMS.dup

    case user
    when ->(u) { u.admin? }
      # NOOP
    when ->(u) { u.staff? }
      # NOOP
    else
      params = []
    end

    params
  end
end
