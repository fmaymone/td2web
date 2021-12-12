# frozen_string_literal: true

# == Schema Information
#
# Table name: report_templates
#
#  id            :uuid             not null, primary key
#  tenant_id     :uuid             not null
#  diagnostic_id :uuid             not null
#  name          :string           not null
#  state         :string           default("draft"), not null
#  version       :integer          default(1), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class ReportTemplate < ApplicationRecord
  ### Constants
  ALLOWED_PARAMS = %i[name version].freeze

  ### Concerns
  include ReportTemplates::StateMachine
  include Seeds::Seedable

  ### Validations
  validates :name, presence: true, uniqueness: { scope: %i[tenant_id diagnostic_id state version] }
  validates :state, presence: true
  validates :version, presence: true

  ### Scopes

  ### Associations
  belongs_to :diagnostic
  belongs_to :tenant
  has_many :pages, class_name: 'ReportTemplatePage', dependent: :destroy

  ### Callbacks

  ### Instance Methods
end
