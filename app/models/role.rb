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

  ### Concerns
  audited
  include Seeds::Seedable

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
end
