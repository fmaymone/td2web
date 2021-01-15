# frozen_string_literal: true

# == Schema Information
#
# Table name: grants
#
#  id             :uuid             not null, primary key
#  active         :boolean          default(TRUE)
#  user_id        :uuid             not null
#  reference      :string           not null
#  entitlement_id :uuid             not null
#  grantor_id     :uuid
#  grantor_type   :string
#  quota          :integer
#  description    :text
#  staff_notes    :text
#  granted_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Grant < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %i[active user_id reference entitlement_id quota description staff_notes granted_at].freeze

  ### Concerns and Extensions

  ### Associations
  belongs_to :user
  belongs_to :entitlement
  belongs_to :grantor, polymorphic: true, optional: true
  has_many :usages, class_name: 'GrantUsage', dependent: :destroy

  ### Attributes

  ### Validations
  validates :reference, presence: true, inclusion: AppContext.list
  validate :user_and_entitlement_role

  ### Callbacks
  before_validation :set_default_reference

  ### Scopes
  scope :valid, lambda {
                  where(active: true)
                    .where(arel_table[:granted_at].lt(DateTime.now))
                }

  ### Class Methods

  ### Instance Methods

  def user_and_entitlement_role
    return unless entitlement.present? && user.present? && grantor.present?

    errors.add :entitlement, "Grantor does not have permission to grant an entitlement for #{entitlement.role.name} accounts" if entitlement.role > grantor.role
    errors.add :user_id, "User does not have sufficient privilege to receive this entitlement for #{entitlement.role.name} accounts" if entitlement.role > user.role
  end

  def usage_count
    usages.count
  end

  def over_quota?
    quota&.positive? && usage_count >= quota
  end

  def effective?
    active? && granted_at < DateTime.now && !over_quota?
  end

  def use!
    return false if over_quota?

    usages.create!
  end

  private

  def set_default_reference
    self.reference ||= entitlement&.reference
  end
end
