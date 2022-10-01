class HomePolicy < ApplicationPolicy
  def index?
    true
  end

  def request_consent?
    true
  end

  def grant_consent?
    true
  end

  def after_registration?
    true
  end

  def system_events?
    user.admin? || suer.staff?
  end
end
