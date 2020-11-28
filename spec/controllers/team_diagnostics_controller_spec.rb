# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamDiagnosticsController, type: :controller do
  render_views
  include_context 'users'
  include_context 'team_diagnostics'

  describe 'GET #index' do
    describe 'logged in as a facilitator' do
      before(:each) do
        sign_in facilitator
      end
      it 'should render successfully' do
        get :index
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET #show' do
    describe 'logged in as a facilitator' do
      before(:each) do
        sign_in facilitator
      end
      it 'redirect to the current wizard step' do
        get :show, params: { id: teamdiagnostic.id }
        expect(response).to redirect_to(wizard_team_diagnostic_path(id: teamdiagnostic.id, step: teamdiagnostic.wizard))
      end
    end
  end

  describe 'GET #new' do
    describe 'logged in as a facilitator' do
      before(:each) do
        sign_in facilitator
      end
      it 'should render the new team diagnostic form successfully' do
        get :new, params: {}
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST #create' do
    describe 'Logged in as a facilitator' do
      let(:valid_attributes) { attributes_for(:team_diagnostic, user_id: facilitator.id, organization_id: organization.id, diagnostic_id: team_diagnostic.id) }
      let(:invalid_attributes) { valid_attributes.merge({ name: nil }) }
      before(:each) do
        sign_in facilitator
      end

      describe 'with valid attributes' do
        it 'should create a new Team Diagnostic' do
          count = TeamDiagnostic.count
          post :create, params: { team_diagnostic: valid_attributes }
          new_team_diagnostic = assigns[:team_diagnostic]
          expect(response).to redirect_to(team_diagnostic_path(new_team_diagnostic))
          expect(TeamDiagnostic.count).to eq(count + 1)
        end
      end

      describe 'with invalid attributes' do
        it 'should rerender the new Team Diagnostic form' do
          count = TeamDiagnostic.count
          post :create, params: { team_diagnostic: invalid_attributes }
          expect(response).to render_template(:new)
          expect(TeamDiagnostic.count).to eq(count)
        end
      end
    end
  end

  describe 'GET #edit' do
    describe 'Logged in as a facilitator' do
      before(:each) do
        sign_in facilitator
      end

      it 'should render the edit form' do
        get :edit, params: { id: teamdiagnostic.id }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'GET #wizard' do
    describe 'Logged in as a facilitator' do
      before(:each) do
        sign_in facilitator
      end

      it 'should render the wizard form' do
        get :wizard, params: { id: teamdiagnostic.id, step: 1 }
        expect(response).to render_template(:wizard)
      end

      it 'should render the wizard form for the specified step' do
        teamdiagnostic.wizard = TeamDiagnostics::Wizard::DEPLOY_STEP
        teamdiagnostic.save!
        teamdiagnostic.reload
        assert(teamdiagnostic.setup?)
        get :wizard, params: { id: teamdiagnostic.id, step: TeamDiagnostics::Wizard::PARTICIPANTS_STEP }
        expect(response).to be_successful
      end

      it 'should render the wizard form for the latest step' do
        teamdiagnostic.wizard = 3
        teamdiagnostic.save!
        get :wizard, params: { id: teamdiagnostic.id, step: 100 }
        expect(response).to render_template(:wizard)
        expect(assigns[:service].step).to eq(teamdiagnostic.wizard)
      end
    end
  end

  describe 'PUT #update' do
    describe 'Logged in as a facilitator' do
      let(:valid_attributes) { { name: 'new_name', due_at: Time.now + 2.days, reminder_at: Time.now + 1.day } }
      let(:invalid_attributes) { valid_attributes.merge({ name: nil }) }
      before(:each) do
        sign_in facilitator
      end

      describe 'with valid params' do
        it 'should update the team diagnostic' do
          old_name = teamdiagnostic.name
          old_due_at = teamdiagnostic.due_at
          put :update, params: { id: teamdiagnostic.id, team_diagnostic: valid_attributes }
          expect(response).to redirect_to(team_diagnostic_path(teamdiagnostic))
          teamdiagnostic.reload
          expect(teamdiagnostic.name).to_not eq(old_name)
          expect(teamdiagnostic.due_at).to_not eq(old_due_at)
        end
      end

      describe 'with invalid params' do
        it 'should re-render the wizard step page' do
          old_name = teamdiagnostic.name
          put :update, params: { id: teamdiagnostic.id, team_diagnostic: invalid_attributes }
          expect(response).to render_template(:wizard)
          teamdiagnostic.reload
          expect(teamdiagnostic.name).to eq(old_name)
        end
      end
    end
  end

  describe 'POST @deploy' do
    describe 'as a facilitator' do
      before(:each) do
        diagnostic_seed_data
        diagnostic_question_seed_data
        organization
        teamdiagnostic_participants
        sign_in facilitator
      end

      it 'should deploy the Team Diagnostic' do
        teamdiagnostic.wizard = teamdiagnostic.total_wizard_steps
        teamdiagnostic.save!
        post :deploy, params: { id: teamdiagnostic.id }
        teamdiagnostic.reload
        assert(teamdiagnostic.deployed?)
      end

      describe 'if there are problems' do
        it 'should deploy the Team Diagnostic' do
          teamdiagnostic.wizard = teamdiagnostic.total_wizard_steps
          teamdiagnostic.save!
          teamdiagnostic.participants.destroy_all
          post :deploy, params: { id: teamdiagnostic.id }
          teamdiagnostic.reload
          refute(teamdiagnostic.deployed?)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    describe 'as a facilitator' do
      before(:each) do
        sign_in facilitator
      end

      it 'should fail with an error' do
        expect  do
          delete :destroy, params: { id: teamdiagnostic.id }
        end.to raise_error(StandardError)
      end
    end
  end
end
