# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamDiagnosticsController, type: :controller do
  render_views
  include_context 'users'
  include_context 'team_diagnostics'

  let(:subject) { teamdiagnostic_ready }

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
        get :show, params: { id: subject.id }
        expect(response).to redirect_to(wizard_team_diagnostic_path(id: subject.id, step: subject.wizard))
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
      let(:valid_attributes) { attributes_for(:team_diagnostic, user_id: facilitator.id, organization_id: organization.id, diagnostic_id: tda_diagnostic.id) }
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
        get :edit, params: { id: subject.id }
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
        get :wizard, params: { id: subject.id, step: 1 }
        expect(response).to render_template(:wizard)
      end

      it 'should render the wizard form for the specified step' do
        assert(subject.setup?)

        subject.wizard = 2
        subject.save!
        subject.reload
        get :wizard, params: { id: subject.id, step: 2 }

        TeamDiagnostic::WIZARD_STEPS.each_with_index do |_step, index|
          subject.wizard = index + 1
          subject.save!
          subject.reload
          get :wizard, params: { id: subject.id, step: index + 1 }
          expect(response).to be_successful
        end
      end

      it 'should render the wizard form for the latest step' do
        subject.wizard = 3
        subject.save!
        get :wizard, params: { id: subject.id, step: 100 }
        expect(response).to render_template(:wizard)
        expect(assigns[:service].step).to eq(subject.wizard)
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
          old_name = subject.name
          old_due_at = subject.due_at
          put :update, params: { id: subject.id, team_diagnostic: valid_attributes }
          expect(response).to redirect_to(team_diagnostic_path(subject))
          subject.reload
          expect(subject.name).to_not eq(old_name)
          expect(subject.due_at).to_not eq(old_due_at)
        end
      end

      describe 'with invalid params' do
        it 'should re-render the wizard step page' do
          old_name = subject.name
          put :update, params: { id: subject.id, team_diagnostic: invalid_attributes }
          expect(response).to render_template(:wizard)
          subject.reload
          expect(subject.name).to eq(old_name)
        end
      end

      describe 'assigning all new letters' do
        before(:each) do
          # teamdiagnostic_participants
        end
        describe 'with all having valid params' do
          let(:valid_letters_attributes) do
            [
              { letter_type: 'cover', subject: 'cover Subject', body: 'cover body', locale: 'en' },
              { letter_type: 'cover', subject: 'cover Subject de', body: 'cover body de', locale: 'de' },
              { letter_type: 'reminder', subject: 'reminder Subject', body: 'reminder body' },
              { letter_type: 'cancellation', subject: 'cancellation Subject', body: 'cancellation body' }
            ]
          end
          let(:valid_attributes) { { team_diagnostic_letters_attributes: valid_letters_attributes } }
          it 'should create associated letters' do
            subject.team_diagnostic_letters.destroy_all
            put :update, params: { id: subject.id, team_diagnostic: valid_attributes }
            subject.reload
            expect(subject.team_diagnostic_letters.count).to eq(valid_letters_attributes.size)
            expect(response).to be_a_redirect
          end
        end
        describe 'with some having invalid params'
      end

      describe 'assiging two new letters' do
        describe 'with both having valid params'
        describe 'with one having invalid params'
      end

      describe 'updating two letters' do
        describe 'with both having valid params'
        describe 'with one having invalid params'
      end
    end
  end

  describe 'POST @deploy' do
    describe 'as a facilitator' do
      let(:subject) { teamdiagnostic_ready }
      before(:each) do
        diagnostic_seed_data
        diagnostic_question_seed_data
        organization
        sign_in facilitator
      end

      it 'should deploy the Team Diagnostic' do
        subject.wizard = subject.total_wizard_steps
        subject.save!
        post :deploy, params: { id: subject.id }
        subject.reload
        assert(subject.deployed?)
      end

      describe 'if there are problems' do
        it 'should not deploy the Team Diagnostic' do
          subject.wizard = subject.total_wizard_steps
          subject.save!
          subject.participants.destroy_all
          assert(subject.deployment_issues?)
          post :deploy, params: { id: subject.id }
          subject.reload
          refute(subject.deployed?)
        end
      end
    end
  end

  describe 'POST #cancel' do
    describe 'as a facilitator' do
      let(:subject) { teamdiagnostic_ready }
      before(:each) do
        diagnostic_seed_data
        diagnostic_question_seed_data
        organization
        subject.state = 'deployed'
        subject.save
        subject.reload
        sign_in facilitator
      end

      it 'should cancel the Team Diagnostic' do
        post :cancel, params: { id: subject.id }
        subject.reload
        assert(subject.cancelled?)
      end
    end
  end

  describe 'POST #complete' do
    describe 'as a facilitator' do
      let(:subject) { teamdiagnostic_ready }
      before(:each) do
        diagnostic_seed_data
        diagnostic_question_seed_data
        organization
        subject.state = 'deployed'
        subject.save
        subject.reload
        sign_in facilitator
      end

      it 'should cancel the Team Diagnostic' do
        post :complete, params: { id: subject.id }
        subject.reload
        assert(subject.completed?)
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
          delete :destroy, params: { id: subject.id }
        end.to raise_error(StandardError)
      end
    end
  end
end
