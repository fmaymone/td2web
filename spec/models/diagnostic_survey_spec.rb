# frozen_string_literal: true

# == Schema Information
#
# Table name: diagnostic_surveys
#
#  id                 :uuid             not null, primary key
#  team_diagnostic_id :uuid             not null
#  participant_id     :uuid             not null
#  state              :string           default("pending"), not null
#  locale             :string           default("en"), not null
#  notes              :text
#  last_activity_at   :datetime
#  delivered_at       :datetime
#  started_at         :datetime
#  completed_at       :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
require 'rails_helper'

RSpec.describe DiagnosticSurvey, type: :model do
  include_context 'users'
  include_context 'organizations'
  include_context 'diagnostics'

  let(:teamdiagnostic) { create(:team_diagnostic, user_id: facilitator.id, organization_id: organization.id, diagnostic_id: tda_diagnostic.id) }
  let(:participant) { create(:participant, team_diagnostic: teamdiagnostic, state: :approved) }
  let(:diagnostic_survey) { create(:diagnostic_survey, participant:, team_diagnostic: teamdiagnostic) }
  let(:diagnostic_survey2) { create(:diagnostic_survey, participant:, team_diagnostic: teamdiagnostic, state: :active) }

  describe 'state machine' do
    it 'can be activated if there are no other active Surveys' do
      diagnostic_survey
      diagnostic_survey2
      expect do
        refute(diagnostic_survey.activate!)
      end.to raise_error(AASM::InvalidTransition)
      diagnostic_survey2.destroy
      assert(diagnostic_survey.activate!)
    end
    it 'sends the TeamDiagnostic cover letter/invitiation upon activation' do
      count = ActionMailer::Base.deliveries.count
      assert(diagnostic_survey.activate!)
      expect(ActionMailer::Base.deliveries.count).to eq(count + 1)
    end
  end
end
