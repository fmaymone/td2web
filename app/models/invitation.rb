# frozen_string_literal: true

# == Schema Information
#
# Table name: invitations
#
#  id            :uuid             not null, primary key
#  tenant_id     :uuid
#  active        :boolean          default(TRUE)
#  token         :string
#  grantor_id    :uuid
#  grantor_type  :string
#  entitlements  :jsonb
#  email         :string
#  description   :text
#  redirect      :string
#  locale        :string           default("en")
#  i18n_key      :string
#  claimed_at    :datetime
#  claimed_by_id :uuid
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Invitation < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %i[active entitlements email description i18n_key redirect].freeze
  I18N_KEY_BASE = 'invitation-message'

  ### Concerns
  max_paginates_per 15

  ### Validations
  validates :token, presence: true
  validates :email, presence: true
  validates :i18n_key, presence: true
  validate :entitlements_are_valid

  ### Scopes

  ### Associations
  belongs_to :grantor, polymorphic: true
  belongs_to :tenant
  belongs_to :claimed_by, class_name: 'User', required: false

  ### Callbacks
  before_validation :generate_token, on: :create

  serialize :entitlements

  ### Scopes
  scope :unclaimed, -> { where(claimed_at: nil, active: true) }

  ### Class Methods

  def self.find_by_tenant_and_token(token:, tenant:)
    Invitation.unclaimed
              .where(token:, tenant_id: tenant.id)
              .order(created_at: :asc)
              .limit(1).first
  end

  ### Public Methods

  def claimed?
    claimed_at.present?
  end

  def claim!
    self.claimed_at = Time.now
    save!
  end

  def assigned_entitlements
    entitlements.map do |entitlement_record|
      data = entitlement_record.with_indifferent_access
      entitlement = Entitlement.where(id: data[:id]).first
      next unless entitlement.present?

      quota = data[:quota] || 1
      { entitlement:, quota: }
    end.compact
  end

  def limited?
    assigned_entitlements.map { |ae| ae[:entitlement] }.any?(&:account?)
  end

  def email_body
    # TODO: Improve security: strip unnecessary html tags
    with_locale(locale) do
      template = Liquid::Template.parse(i18n_key.t)
      template.render(template_params)
    end.html_safe
  end

  def email_subject
    with_locale(locale) do
      subject_key = "#{Invitation::I18N_KEY_BASE}-subject"
      template = Liquid::Template.parse(subject_key.t)
      template.render(template_params)
    end
  end

  def template_params
    {
      'domain' => tenant.domain,
      'email' => email,
      'invitation_link' => Rails.application.routes.url_helpers
                                .claim_invitations_url(token:, host: Rails.application.config.application_host_and_port)
    }
  end

  private

  def with_locale(locale)
    output = ''
    old_locale = I18n.locale
    I18n.locale = locale
    output = yield
  ensure
    I18n.locale = old_locale
    output
  end

  def entitlements_are_valid
    self.entitlements ||= []
    errors.add(:entitlements, 'must be present'.t) unless entitlements.present?
    entitlements.each do |entitlement|
      data = entitlement.with_indifferent_access
      assoc_entitlement = Entitlement.where(id: data[:id]).first
      assoc_quota = data[:quota]
      errors.add(:entitlements, 'has an invalid reference'.t) unless assoc_entitlement.present?
      errors.add(:entitlements, 'must have a quota') unless assoc_quota&.to_i&.positive?
    end
  end

  def generate_token
    self.token ||= SecureRandom.uuid
  end
end
