# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosticSurveysController, type: :controller do
  render_views
  include_context 'users'
  include_context 'team_diagnostics'

  let(:diagnostic_survey) { teamdiagnostic_deployed.diagnostic_surveys.first }

  describe 'GET #index' do
    it 'should raise 404' do
      expect do
        get :index
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'GET #new' do
    it 'should raise 404' do
      expect do
        get :new
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'DELETE #destroy' do
    it 'should raise 404' do
      expect do
        delete :destroy, params: { id: diagnostic_survey.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'GET #show' do
    describe 'with an active DiagnosticSurvey\'s id' do
      it 'should render the show page' do
        get :show, params: { id: diagnostic_survey.id }
        expect(response).to render_template('show')
      end
    end
    describe 'with a non-active DiagnosticSurvey\'s id' do
      it 'should render a 404' do
        diagnostic_survey.state = 'cancelled'
        diagnostic_survey.save!
        expect do
          get :show, params: { id: diagnostic_survey.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    describe 'with a nonexistent DiagnosticSurvey id' do
      it 'should render a 404' do
        expect do
          get :show, params: { id: 0 }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET #edit' do
    describe 'with an active DiagnosticSurvey\'s id' do
      it 'should render the show page' do
        get :edit, params: { id: diagnostic_survey.id }
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'PUT #update' do
    let(:question) { diagnostic_survey.questions.first }
    describe 'submitting a valid response' do
      it 'should create a response record' do
        response_count = diagnostic_survey.diagnostic_responses.count

        put :update, params: { id: diagnostic_survey.id, team_diagnostic_question_id: question.id, response: '5' }
        diagnostic_survey.reload
        expect(diagnostic_survey.diagnostic_responses.count).to eq(response_count + 1)
      end
      describe 'for the first time' do
        it 'should create a system event' do
          put :update, params: { id: diagnostic_survey.id, team_diagnostic_question_id: question.id, response: '5' }
          event = SystemEvent.where(incidental: diagnostic_survey.participant).order(created_at: :desc).first
          expect(event.description).to eq('The Diagnostic Survey was started')
          expect(event.event_source).to eq(diagnostic_survey.team_diagnostic)
        end
      end
      describe 'for the final question' do
        it 'should create a system event' do
          svc = DiagnosticSurveyServices::QuestionService.new(diagnostic_survey: diagnostic_survey)
          all_questions = svc.all_questions
          all_questions[0..].each do |q|
            svc.answer_question(question: q, response: '1')
          end
          last_question = all_questions.last
          put :update, params: { id: diagnostic_survey.id, team_diagnostic_question_id: last_question.id, response: '5' }
          event = SystemEvent.where(incidental: diagnostic_survey.participant).order(created_at: :desc).first
          expect(event.description).to eq('The Diagnostic Survey was completed')
          expect(event.event_source).to eq(diagnostic_survey.team_diagnostic)
        end
      end
    end
    describe 'with an invalid question id' do
      it 'should raise a 404' do
        expect do
          put :update, params: { id: diagnostic_survey.id, team_diagnostic_question_id: 'foobar', response: '5' }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    describe 'with an invalid response' do
      it 'should redirect back to question UI' do
        put :update, params: { id: diagnostic_survey.id, team_diagnostic_question_id: question.id }
        expect(response).to redirect_to(edit_diagnostic_survey_path(id: diagnostic_survey.id))
      end
    end
  end
end
