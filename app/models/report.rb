# frozen_string_literal: true

# == Schema Information
#
# Table name: reports
#
#  id                 :uuid             not null, primary key
#  team_diagnostic_id :uuid
#  report_template_id :uuid
#  state              :string           default("pending"), not null
#  version            :integer          default(1), not null
#  started_at         :datetime
#  completed_at       :datetime
#  description        :string
#  note               :text
#  token              :uuid
#  chart_data         :json
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  options            :json
#
class Report < ApplicationRecord
  ### Constants

  ### Concerns
  include Reports::StateMachine
  include Reports::Files
  include Reports::Pages

  ### Validations

  ### Scopes

  ### Associations
  belongs_to :team_diagnostic
  belongs_to :report_template
  has_many :system_events, as: :event_source

  ### Callbacks
  before_validation :reset_token

  ### Instance Methods

  def event_description
    team_diagnostic.name
  end

  def reset_token
    self.token = Digest::UUID.uuid_v4
  end

end
