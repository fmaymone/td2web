# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id          :uuid             not null, primary key
#  slug        :string           not null
#  name        :string           not null
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
### User Roles
class Role < ApplicationRecord
  ADMIN_ROLE = 'admin'
  STAFF_ROLE = 'staff'
  TRANSLATOR_ROLE = 'translator'
  FACILITATOR_ROLE = 'facilitator'
  MEMBER_ROLE = 'member'
  HIERARCHY = %w[ADMIN_ROLE STAFF_ROLE TRANSLATOR_ROLE FACILITATOR_ROLE MEMBER_ROLE].freeze

  ### Concerns
  include Comparable
  include Seeds::Seedable
  audited

  ### Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  ### Class Methods

  class << self
    def admin
      where(slug: ADMIN_ROLE).first
    end

    def staff
      where(slug: STAFF_ROLE).first
    end

    def translator
      where(slug: TRANSLATOR_ROLE).first
    end

    def facilitator
      where(slug: FACILITATOR_ROLE).first
    end

    def member
      where(slug: MEMBER_ROLE).first
    end
  end

  ### Instance Methods

  def admin?
    slug == ADMIN_ROLE
  end

  def staff?
    slug == STAFF_ROLE
  end

  def translator?
    slug == TRANSLATOR_ROLE
  end

  def facilitator?
    slug == FACILITATOR_ROLE
  end

  def member?
    slug == MEMBER_ROLE
  end

  def <=>(other)
    return 1 if other.nil?
    return 1 if HIERARCHY.index(other.slug&.to_sym).nil?
    return -1 if HIERARCHY.index(slug.to_sym).nil?

    HIERARCHY.index(other.slug.to_sym) <=> HIERARCHY.index(slug.to_sym)
  end
end
