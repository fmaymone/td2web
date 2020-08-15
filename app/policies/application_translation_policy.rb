# frozen_string_literal: true

# Translation Policy
class ApplicationTranslationPolicy < ApplicationPolicy
  # Translation Policy scope
  class Scope
    def resolve
      ApplicationTranslation
    end
  end

  def index?
    user.admin? || user.staff? || user.translator?
  end

  def new?
    user.admin? || user.staff? || user.translator?
  end

  def create?
    new?
  end

  def show?
    index?
  end

  def edit?
    user.admin? || user.staff? || user.translator?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  def allowed_params
    translation_params = ApplicationTranslation::ALLOWED_PARAMS.dup
    case user
    when ->(u) { u.admin? }
      # noop
    when ->(u) { u.staff? }
      # noop
    else
      translation_params = []
    end
    translation_params
  end
end
