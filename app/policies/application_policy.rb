# frozen_string_literal: true

# Base Policy
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def admin?
    user.admin?
  end

  def staff?
    user.staff?
  end

  def translator?
    user.translator?
  end

  def facilitator?
    user.facilitator?
  end

  def member?
    user.member?
  end

  def owner?
    record.respond_to?(:user) && record.user.id == user.id
  end

  # Base Scope
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
