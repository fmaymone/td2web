# frozen_string_literal: true

# == Schema Information
#
# Table name: organization_users
#
#  id              :uuid             not null, primary key
#  organization_id :uuid             not null
#  user_id         :uuid             not null
#  role            :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class OrganizationUser < ApplicationRecord
  ### Enums
  enum role: { admin: 0, member: 1 }

  ### Associations
  belongs_to :organization
  belongs_to :user

  ### Validations
  validates :user_id, uniqueness: { scope: :organization_id, message: 'is already a member of this organization' }

  scope :admins, -> { where(role: 'admin')}
end
