# frozen_string_literal: true

# User Policy
class UserPolicy < ApplicationPolicy
  # User Policy Scope
  class Scope < Scope
    def resolve
      skope = scope
      case user
      when ->(u) { u.admin? }
        skope.where(tenant: user.tenant)
      when ->(u) { u.staff? }
        skope.where(tenant: user.tenant)
      when ->(u) { u.translator? }
        skope.where(id: user.id)
      when ->(u) { u.facilitator? }
        skope.where(id: user.id)
      when ->(u) { u.member? }
        skope.where(id: user.id)
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
    admin? || staff?
  end

  def show?
    user == record || admin? || staff?
  end

  def manage_grants?
    admin? || staff?
  end

  def edit?
    case user
    when ->(u) { record.is_a?(User) && record.id == u.id }
      true
    when ->(u) { u.admin? }
      user.role >= record.role
    when ->(u) { u.staff? }
      (user.role >= record.role)
    else
      user == record
    end
  end

  def update?
    edit?
  end

  def destroy?
    user.id != record.id && edit?
  end

  def edit_staff_notes?
    user.admin? || user.staff?
  end

  def consent?
    update_consent?
  end

  def update_consent?
    record.is_a?(User) && record.id == user.id
  end

  def admin_preferences?
    user.admin? || user.staff?
  end

  def admin_notify_errors?
    admin_preferences? && user.notification_admin_errors?
  end

  def allowed_params
    user_params = User::ALLOWED_PARAMS.dup
    profile_params = UserProfile::ALLOWED_PARAMS.dup
    profile_params << [{ consent: UserProfile::CONSENT_PARAMS.dup }] if update_consent?

    case user
    when ->(u) { u.admin? }
      user_params << [:role_id]
      profile_params << %i[staff_notes ux_version notification_admin_errors]
    when ->(u) { u.staff? }
      user_params << [:role_id]
      profile_params << %i[staff_notes ux_version notification_admin_errors]
    when ->(u) { u.translator? }
      # noop
    when ->(u) { u.facilitator? }
      # noop
    when ->(u) { u.member? }
      # noop
    else
      user_params = []
      profile_params = []
    end

    user_params + [{ user_profile_attributes: profile_params }]
  end
end
