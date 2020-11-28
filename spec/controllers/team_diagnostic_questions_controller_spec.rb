# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamDiagnosticQuestionsController, type: :controller do
  render_views
  include_context 'users'
  include_context 'team_diagnostics'

  let(:diagnostic_question) { teamdiagnostic.diagnostic.diagnostic_questions.open_ended.first }

  describe 'POST #create' do
    before(:each) do
      sign_in facilitator
    end
    describe 'with valid attributes' do
      before(:each) do
        diagnostic_seed_data
        diagnostic_question_seed_data
      end
      let(:new_question_body) { 'foobar12' }
      it 'should create a team diagnostic question given a body' do
        count = teamdiagnostic.questions.count
        post :create, format: :js, params: { team_diagnostic_id: teamdiagnostic.id, team_diagnostic_question: { body: new_question_body } }
        expect(TeamDiagnosticQuestion.count).to eq(count + 1)
        expect(response).to render_template('team_diagnostics/_open_ended_questions')
      end
      it 'should create a team diagnostic question given a Diagnostic Question ID' do
        count = teamdiagnostic.questions.count
        post :create, format: :js, params: { team_diagnostic_id: teamdiagnostic.id, diagnostic_question_id: diagnostic_question.id }
        expect(TeamDiagnosticQuestion.count).to eq(count + 1)
        expect(response).to render_template('team_diagnostics/_open_ended_questions')
        teamdiagnostic.reload
        expect(teamdiagnostic.questions.last.body).to eq(diagnostic_question.body)
      end
    end
    describe 'with invalid attributes' do
      let(:new_question_body) { 'foobar12' }
      it 'should create a team diagnostic question given a body' do
        count = teamdiagnostic.questions.count
        post :create, format: :js, params: { team_diagnostic_id: teamdiagnostic.id, team_diagnostic_question: { body: nil } }
        expect(TeamDiagnosticQuestion.count).to eq(count)
        expect(response).to_not have_http_status(200)
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) { sign_in facilitator }
    it 'should delete the question' do
      create(:team_diagnostic_question, team_diagnostic: teamdiagnostic)
      count = teamdiagnostic.questions.count
      delete :destroy, format: :js, params: { team_diagnostic_id: teamdiagnostic.id, id: teamdiagnostic.questions.last.id }
      expect(teamdiagnostic.questions.count).to eq(count - 1)
    end
  end
end
