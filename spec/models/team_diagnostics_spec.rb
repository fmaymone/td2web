# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamDiagnostic, type: :model do
  include_context 'users'
  include_context 'organizations'
  include_context 'team_diagnostics'
  include_context 'report_templates'

  let(:participant) { create(:participant, team_diagnostic: teamdiagnostic) }
  let(:subject) { teamdiagnostic_ready }

  describe 'initialization' do
    it 'can be saved' do
      subject = build(:team_diagnostic, user: facilitator, organization:, diagnostic: tda_diagnostic)
      assert(subject.save)
    end
  end

  describe 'validation' do
    it 'only allows assignment to an organization owned by user' do
      assert(subject.valid?)
      subject.organization = organization2
      refute(subject.valid?)
    end
    it 'may only be assigned a valid state' do
      assert(subject.valid?)
      subject.state = 'foobar'
      refute(subject.valid?)
      subject.state = 'completed'
      assert(subject.valid?)
    end
  end

  describe 'associations' do
    it 'includes a user' do
      expect(subject.user).to eq(facilitator)
    end
    it 'includes an organization' do
      expect(subject.organization).to eq(organization)
    end
    it 'includes a diagtnostic' do
      expect(subject.diagnostic).to eq(tda_diagnostic)
    end
    it 'optionally includes a reference_diagnostic (subject)' do
      expect(subject.reference_diagnostic).to be_nil
    end
  end

  describe 'Auto Deployment' do
    describe 'without errors' do
      it 'deploys all team diagnostics pending auto deploy' do
        subject.save
        subject.auto_deploy_at = Time.now + 1.day
        subject.save
        assert(subject.setup?)
        TeamDiagnostic.auto_deploy
        subject.reload
        assert(subject.setup?)
        subject.auto_deploy_at = 1.day.ago
        subject.save
        TeamDiagnostic.auto_deploy
        subject.reload
        assert(subject.deployed?)
      end
    end
  end

  describe 'reporting' do
    describe 'performing report' do
      it 'should create a report if the diagnostic is completed' do
        completed_teamdiagnostic.auto_respond
        completed_teamdiagnostic.reload
        completed_teamdiagnostic.report!
        completed_teamdiagnostic.reload
        report = completed_teamdiagnostic.reports.first
        expect(report.chart_data.keys.count).to be >= 2
      end
    end
  end

  describe 'state machine' do
    it 'is initially in the "setup" state' do
      expect(subject.state).to eq(TeamDiagnostic::STATE_SETUP.to_s)
    end
    it 'can only be deployed from the setup state' do
      assert(subject.deploy!)
      expect(subject.state).to eq(TeamDiagnostic::STATE_DEPLOYED.to_s)
      expect(subject.permitted_state_events).to_not include('deploy')
      expect(subject.permitted_states).to_not include(TeamDiagnostic::STATE_SETUP.to_s)
      refute(subject.trigger_event(event_name: 'deploy'))
    end

    describe 'upon deployment' do
      include_context 'team_diagnostics'

      before(:each) do
        diagnostic_seed_data
        diagnostic_question_seed_data
        organization
      end
      it 'should set deployed_at' do
        assert(subject.setup?)
        subject.deployed_at = nil
        subject.save
        assert(subject.deployed_at.nil?)
        assert(subject.deploy!)
        assert(subject.deployed_at.present?)
      end
      it 'should be assigned questions' do
        assert(subject.questions.empty?)
        assert(subject.deploy)
        assert(subject.deployed?)
        expect(subject.questions.count).to be_positive
      end

      it 'should not transition to the deployed state if there is an issue with performing the deployment' do
        # Here we test deployment failure due to a missing Diagnostic association
        diagnostic = subject.diagnostic
        subject.diagnostic = nil
        expect do
          subject.deploy!
        end.to raise_error(AASM::InvalidTransition)
        refute(subject.deployed?)
        subject.diagnostic = diagnostic
        begin
          subject.deploy!
        rescue StandardError
          true
        end
        assert(subject.deployed?)
      end

      it 'should reset assigned questions if they are already present' do
        subject.send :assign_questions
        subject.reload
        refute(subject.questions.empty?)
        old_qids = subject.questions.pluck(:id)
        subject.deploy!
        subject.reload
        refute(old_qids.include?(subject.questions.first.id))
        expect(subject.questions.count).to eq(old_qids.size)
      end

      it 'should activate participants' do
        assert(subject.participants.any?)
        assert(subject.participants.approved.count == subject.participants.count)
        refute(subject.participants.active.any?)
        assert(subject.deploy!)
        subject.reload
        expect(subject.participants.active.count).to eq(subject.participants.count)
      end

      it 'should email the facilitator and participants' do
        count = ActionMailer::Base.deliveries.count
        assert(subject.deploy!)
        subject.reload
        expect(ActionMailer::Base.deliveries.count).to eq(count + subject.participants.active.count + 1)
      end

      describe 'upon redeployment' do
        it 'should transition to deployed' do
          subject.deploy!
          subject.reload
          assert subject.deployed?

          subject.cancel!
          subject.reload
          assert subject.cancelled?

          subject.deploy!
          subject.reload
          assert subject.deployed?
        end
      end
    end
  end
end
