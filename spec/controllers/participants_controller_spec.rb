# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ParticipantsController, type: :controller do
  render_views
  include_context 'users'
  include_context 'team_diagnostics'

  let(:valid_attributes) { attributes_for(:participant, team_diagnostic: teamdiagnostic) }
  let(:invalid_attributes) { valid_attributes.merge(email: nil) }
  let(:participant) { create(:participant, team_diagnostic: teamdiagnostic, state: 'approved') }

  # describe 'GET #index' do
  # end

  describe 'GET #new' do
    describe 'Logged in as a facilitator' do
      before(:each) { sign_in facilitator }

      it 'should render the new participant form' do
        get :new, params: { team_diagnostic_id: teamdiagnostic.id }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST #create' do
    describe 'logged in as a facilitator' do
      before(:each) { sign_in facilitator }

      describe 'with valid attributes' do
        it 'should create a new participant' do
          count = Participant.count
          post :create, params: { team_diagnostic_id: teamdiagnostic.id, participant: valid_attributes }
          expect(Participant.count).to eq(count + 1)
          expect(response).to redirect_to(new_team_diagnostic_participant_path(team_diagnostic_id: teamdiagnostic.id))
        end
      end

      describe 'with invalid attributes' do
        it 'should fail to create a participant' do
          count = Participant.count
          post :create, params: { team_diagnostic_id: teamdiagnostic.id, participant: invalid_attributes }
          expect(Participant.count).to eq(count)
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'GET #edit' do
    describe 'logged in as a facilitator' do
      before(:each) { sign_in facilitator }
      it 'should render the edit view' do
        get :edit, params: { team_diagnostic_id: teamdiagnostic.id, id: participant.id }
        expect(response).to be_successful
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'PUT #update' do
    describe 'logged in as a facilitator' do
      let(:valid_attributes) { { email: 'fooabr@example.com' } }
      let(:invalid_attributes) { { email: '' } }
      before(:each) { sign_in facilitator }
      describe 'using valid attributes' do
        it 'should update the participant record' do
          old_email = participant.email
          put :update, params: { team_diagnostic_id: teamdiagnostic.id, id: participant.id, participant: valid_attributes }
          participant.reload
          expect(participant.email).to_not eq(old_email)
          expect(response).to be_a_redirect
        end
      end

      describe 'using invalid attributes' do
        it 'should not update the participant record' do
          old_email = participant.email
          put :update, params: { team_diagnostic_id: teamdiagnostic.id, id: participant.id, participant: invalid_attributes }
          participant.reload
          expect(participant.email).to eq(old_email)
          expect(response).to render_template('edit')
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    describe 'logged in as a facilitator' do
      before(:each) { sign_in facilitator }
      it 'should delete the participant record' do
        participant
        count = Participant.count
        delete :destroy, params: { id: participant.id, team_diagnostic_id: teamdiagnostic.id }
        expect(Participant.count).to eq(count - 1)
      end
    end
  end

  describe 'GET #index' do
    describe 'logged in as a facilitator' do
      before(:each) { sign_in facilitator }
      it 'should render the participant list' do
        get :index, params: { team_diagnostic_id: teamdiagnostic.id }
        expect(response).to render_template(:index)
      end

      describe 'without specifying a teamdiagnostic id' do
        it 'should raise an error' do
          expect do
            get :index
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  describe 'GET #define_import' do
    describe 'logged in as a facilitator' do
      before(:each) { sign_in facilitator }
      it 'should render the form' do
        get :define_import, params: { team_diagnostic_id: teamdiagnostic.id }
        expect(response).to render_template(:define_import)
      end
    end
  end

  describe 'POST #disqualify' do
    describe 'logged in as a facilitator' do
      before(:each) { sign_in facilitator }
      it 'should disqualify the participant' do
        assert(participant.approved?)
        post :disqualify, params: { id: participant.id, team_diagnostic_id: teamdiagnostic.id }
        participant.reload
        assert(participant.disqualified?)
      end
    end
  end

  describe 'POST #restore' do
    describe 'logged in as a facilitator' do
      before(:each) { sign_in facilitator }
      it 'should restore a disqualified participant' do
        participant.disqualify!
        refute(participant.approved?)
        post :restore, params: { id: participant.id, team_diagnostic_id: teamdiagnostic.id }
        participant.reload
        assert(participant.approved?)
      end
    end
  end

  describe 'POST #activate' do
    describe 'logged in as a facilitator' do
      before(:each) { sign_in facilitator }
      it 'should activate n approved participant when the team diagnostic is already deployed' do
        assert(participant.approved?)
        refute(participant.active?)
        teamdiagnostic.state = 'deployed'
        teamdiagnostic.save!
        participant.reload
        expect(teamdiagnostic).to eq participant.team_diagnostic
        post :activate, params: { id: participant.id, team_diagnostic_id: teamdiagnostic.id }
        participant.reload
        assert(participant.active?)
      end
    end
  end

  describe 'POST #resend_invitation' do
    let(:participant) do
      p = create(:participant, team_diagnostic: teamdiagnostic_ready, state: 'approved')
      teamdiagnostic_ready.deploy!
      p.reload
      p
    end
    describe 'logged in as a facilitator' do
      before(:each) { sign_in facilitator }
      it 'should resend an invitation' do
        participant
        email_count = ActionMailer::Base.deliveries.count
        event_count = SystemEvent.count
        post :resend_invitation, params: { id: participant.id, team_diagnostic_id: teamdiagnostic_ready.id }
        expect(SystemEvent.count).to eq(event_count + 1)
        expect(ActionMailer::Base.deliveries.count).to eq(email_count + 1)
        expect(response).to redirect_to(wizard_team_diagnostic_path(id: teamdiagnostic_ready.id, step: TeamDiagnostics::Wizard::PARTICIPANTS_STEP))
      end
    end
  end

  describe 'POST #create_import' do
    let(:valid_csv) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/files/participants.csv", 'text/csv', false) }
    let(:valid_xls) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/files/participants.xls", 'application/vnd.ms-excel', true) }
    let(:valid_xlsx) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/files/participants.xlsx", 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', true) }
    let(:errors_csv) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/files/participants_errors.csv", 'text/csv', false) }
    let(:errors_xls) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/files/participants_errors.xls", 'application/vnd.ms-excel', true) }
    let(:errors_xlsx) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/files/participants_errors.xlsx", 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', true) }
    describe 'logged in as a facilitator' do
      before(:each) { sign_in facilitator }
      describe 'with a valid CSV file' do
        it 'should create participant import records' do
          participant_count = Participant.count
          import_count = teamdiagnostic.participant_imports.count
          post :create_import, params: { team_diagnostic_id: teamdiagnostic.id, participants: valid_csv }
          teamdiagnostic.reload
          service = assigns[:service]
          expect(teamdiagnostic.participant_imports.count).to eq(import_count + 1)
          expect(Participant.count).to eq(participant_count + 3)
          assert(service.valid?)
        end
      end
      describe 'with a valid XLSX file' do
        it 'should create participant import records' do
          participant_count = Participant.count
          import_count = teamdiagnostic.participant_imports.count
          post :create_import, params: { team_diagnostic_id: teamdiagnostic.id, participants: valid_xlsx }
          teamdiagnostic.reload
          service = assigns[:service]
          expect(teamdiagnostic.participant_imports.count).to eq(import_count + 1)
          expect(Participant.count).to eq(participant_count + 3)
          assert(service.valid?)
        end
      end
      describe 'with a valid XLS file' do
        it 'should create participant import records' do
          participant_count = Participant.count
          import_count = teamdiagnostic.participant_imports.count
          post :create_import, params: { team_diagnostic_id: teamdiagnostic.id, participants: valid_xls }
          teamdiagnostic.reload
          service = assigns[:service]
          expect(teamdiagnostic.participant_imports.count).to eq(import_count + 1)
          expect(Participant.count).to eq(participant_count + 3)
          assert(service.valid?)
        end
      end
      describe 'with a valid CSV file with errors' do
        it 'should create participant import records' do
          participant_count = Participant.count
          import_count = teamdiagnostic.participant_imports.count
          post :create_import, params: { team_diagnostic_id: teamdiagnostic.id, participants: errors_csv }
          teamdiagnostic.reload
          service = assigns[:service]
          expect(teamdiagnostic.participant_imports.count).to eq(import_count + 1)
          expect(Participant.count).to eq(participant_count + 1)
          expect(service.stats[:skipped]).to eq(2)
          expect(service.stats[:created]).to eq(1)
          expect(service.stats[:errors].size).to eq(2)
        end
      end
      describe 'with a valid XLS file with errors' do
        it 'should create participant import records' do
          participant_count = Participant.count
          import_count = teamdiagnostic.participant_imports.count
          post :create_import, params: { team_diagnostic_id: teamdiagnostic.id, participants: errors_xls }
          teamdiagnostic.reload
          service = assigns[:service]
          expect(teamdiagnostic.participant_imports.count).to eq(import_count + 1)
          expect(Participant.count).to eq(participant_count + 1)
          expect(service.stats[:skipped]).to eq(2)
          expect(service.stats[:created]).to eq(1)
          expect(service.stats[:errors].size).to eq(2)
        end
      end
      describe 'with a valid XLSX file with errors' do
        it 'should create participant import records' do
          participant_count = Participant.count
          import_count = teamdiagnostic.participant_imports.count
          post :create_import, params: { team_diagnostic_id: teamdiagnostic.id, participants: errors_xlsx }
          teamdiagnostic.reload
          service = assigns[:service]
          expect(teamdiagnostic.participant_imports.count).to eq(import_count + 1)
          expect(Participant.count).to eq(participant_count + 1)
          expect(service.stats[:skipped]).to eq(2)
          expect(service.stats[:created]).to eq(1)
          expect(service.stats[:errors].size).to eq(2)
        end
      end
    end
  end
end
