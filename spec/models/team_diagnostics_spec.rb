# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamDiagnostic, type: :model do
  include_context 'users'
  include_context 'organizations'
  include_context 'diagnostics'

  let(:teamdiagnostic) { create(:team_diagnostic, user_id: facilitator.id, organization_id: organization.id, diagnostic_id: team_diagnostic.id) }

  describe 'initialization' do
    it 'can be saved' do
      teamdiagnostic = build(:team_diagnostic, user: facilitator, organization: organization, diagnostic: team_diagnostic)
      assert(teamdiagnostic.save)
    end
  end

  describe 'validation' do
    it 'only allows assignment to an organization owned by user' do
      assert(teamdiagnostic.valid?)
      teamdiagnostic.organization = organization2
      refute(teamdiagnostic.valid?)
    end
  end

  describe 'associations' do
    it 'includes a user' do
      expect(teamdiagnostic.user).to eq(facilitator)
    end
    it 'includes an organization' do
      expect(teamdiagnostic.organization).to eq(organization)
    end
    it 'includes a diagtnostic' do
      expect(teamdiagnostic.diagnostic).to eq(team_diagnostic)
    end
    it 'optionally includes a reference_diagnostic (TeamDiagnostic)' do
      expect(teamdiagnostic.reference_diagnostic).to be_nil
    end
  end

  describe 'state machine' do
    it 'is initially in the "setup" state' do
      expect(teamdiagnostic.state).to eq(TeamDiagnostic::STATE_SETUP.to_s)
    end
    it 'can only be deployed from the setup state' do
      assert(teamdiagnostic.trigger_event(event_name: 'deploy'))
      expect(teamdiagnostic.state).to eq(TeamDiagnostic::STATE_DEPLOYED.to_s)
      expect(teamdiagnostic.permitted_state_events).to_not include('deploy')
      expect(teamdiagnostic.permitted_states).to_not include(TeamDiagnostic::STATE_SETUP.to_s)
      refute(teamdiagnostic.trigger_event(event_name: 'deploy'))
    end

    describe 'upon deployment' do
      include_context 'team_diagnostics'

      before(:each) do
        diagnostic_seed_data
        diagnostic_question_seed_data
        organization
        teamdiagnostic_participants
      end
      it 'should set deployed_at' do
        assert(teamdiagnostic.setup?)
        teamdiagnostic.deployed_at = nil
        teamdiagnostic.save
        assert(teamdiagnostic.deployed_at.nil?)
        assert(teamdiagnostic.deploy)
        assert(teamdiagnostic.deployed_at.present?)
      end
      it 'should be assigned questions' do
        assert(teamdiagnostic.questions.empty?)
        assert(teamdiagnostic.deploy)
        assert(teamdiagnostic.deployed?)
        expect(teamdiagnostic.questions.count).to be_positive
      end

      it 'should not transition to the deployed state if there is an issue with performing the deployment' do
        diagnostic = teamdiagnostic.diagnostic
        teamdiagnostic.diagnostic = nil
        teamdiagnostic.deploy!
        refute(teamdiagnostic.deployed?)
        teamdiagnostic.diagnostic = diagnostic
        teamdiagnostic.deploy!
        assert(teamdiagnostic.deployed?)
      end

      it 'should reset assigned questions if they are already present' do
        teamdiagnostic.send :assign_questions
        teamdiagnostic.reload
        refute(teamdiagnostic.questions.empty?)
        old_qids = teamdiagnostic.questions.pluck(:id)
        teamdiagnostic.deploy!
        teamdiagnostic.reload
        refute(old_qids.include?(teamdiagnostic.questions.first.id))
        expect(teamdiagnostic.questions.count).to eq(old_qids.size)
      end

      it 'should activate participants' do
        refute(teamdiagnostic.participants.active.any?)
        assert(teamdiagnostic.deploy)
        teamdiagnostic.reload
        expect(teamdiagnostic.participants.active.count).to eq(teamdiagnostic.participants.count)
      end
    end
  end
end
