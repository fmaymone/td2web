# frozen_string_literal: true

# TeamDiagnostic Policy
class TeamDiagnosticPolicy < ApplicationPolicy
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
        skope.where(user_id: user.id)
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
    new? && create_grant_authorized?
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

  def wizard?
    update?
  end

  def destroy?
    update?
  end

  def define_import?
    update?
  end

  def create_import?
    define_import?
  end

  def create_grant_authorized?
    return false unless record&.diagnostic&.present?

    service = EntitlementServices::Authorizer.new(user: user, reference: TeamDiagnosticServices::Creator::REFERENCE)
    service.call("#{TeamDiagnosticServices::Creator::ENTITLEMENT_BASE}-any") ||
      service.call("#{TeamDiagnosticServices::Creator::ENTITLEMENT_BASE}-#{record.diagnostic.slug.downcase}")
  end

  def deploy?
    update? && record&.ready_for_deploy?
  end

  def cancel?
    update? && record&.deployed?
  end

  def complete?
    update? && record&.allow_completion?
  end

  def export?
    (show? && record&.completed?) || record&.reported?
  end

  def entitled_diagnostics
    auth_service = EntitlementServices::Authorizer.new(user: user, reference: TeamDiagnosticServices::Creator::REFERENCE)
    return Diagnostic.active.all if auth_service.call("#{TeamDiagnosticServices::Creator::ENTITLEMENT_BASE}-any")

    Diagnostic.active.all.select do |diagnostic|
      auth_service.call("#{TeamDiagnosticServices::Creator::ENTITLEMENT_BASE}-#{diagnostic.slug.downcase}")
    end
  end

  def modify_setup?
    return false unless record.is_a? TeamDiagnostic

    update? && %w[setup deployed cancelled].include?(record.state)
  end

  def modify_participants?
    modify_setup?
  end

  def modify_questions?
    modify_setup? && (record.setup? || record.cancelled? || record.diagnostic_responses.empty?)
  end

  def modify_letters?
    modify_setup?
  end

  def export_data?
    admin? || staff?
  end

  def download_report?
    show? && record.completed?
  end

  def allowed_params
    TeamDiagnostic::ALLOWED_PARAMS + [{ team_diagnostic_letters_attributes: TeamDiagnosticLetter::ALLOWED_PARAMS + [:id] }]
  end
end
