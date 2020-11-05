# frozen_string_literal: true

# Organization Policy
class OrganizationPolicy < ApplicationPolicy
  # Organization Policy Scope
  class Scope < Scope
    def resolve
      skope = scope
      case user
      when ->(u) { u.admin? }
        skope.where(tenant: user.tenant)
      when ->(u) { u.staff? }
        skope.where(tenant: user.tenant)
      when ->(u) { u.facilitator? }
        skope.includes(:organization_users).where(organization_users: { user_id: user.id })
      else
        skope.where('1=0')
      end
    end
  end

  def index?
    admin? || staff? || facilitator?
  end

  def show?
    admin? || staff? || organization_member?
  end

  def new?
    admin? || staff? ||
      EntitlementServices::Authorizer.new(tenant: user.tenant, user: user, reference: OrganizationServices::Creator::REFERENCE).call
  end

  def create?
    new?
  end

  def edit?
    admin? || staff? || organization_admin?
  end

  def update?
    edit?
  end

  def destroy?
    admin? || organization_admin?
    # TODO: check for presence of Teams
  end

  def organization_member?
    record.members.include?(user)
  end

  def organization_admin?
    return false if record == Organization

    record.admin?(user)
  end

  def allowed_params
    Organization::ALLOWED_PARAMS
  end
end
