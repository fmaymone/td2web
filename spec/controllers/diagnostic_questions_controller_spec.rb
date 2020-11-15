# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosticQuestionsController, type: :controller do
  render_views
  include_context 'translations'
  include_context 'users'
  include_context 'diagnostics'

  let(:team_diagnostic_questions) do
    create_list(:diagnostic_question, 5, diagnostic: team_diagnostic)
  end

  let(:question) { team_diagnostic_questions.first }

  let(:diagnostic_params) { { diagnostic_id: team_diagnostic.id } }

  let(:valid_question_attributes) do
    attributes_for(:diagnostic_question, diagnostic: team_diagnostic.id)
  end

  describe 'Logged in as an Admin' do
    before(:each) do
      team_diagnostic_questions
      sign_in admin
    end

    describe 'GET /index' do
      it 'should be successful' do
        get :index, params: diagnostic_params
        expect(response).to render_template(:index)
      end
    end
    describe 'GET /new' do
      it 'should be successful' do
        get :new, params: diagnostic_params
        expect(response).to render_template(:new)
      end
    end
    describe 'POST /create' do
      describe 'with valid attributes' do
        it 'should be successful' do
          count = DiagnosticQuestion.count
          post :create, params: diagnostic_params.merge({ diagnostic_question: valid_question_attributes })
          expect(response).to be_redirect
          expect(DiagnosticQuestion.count).to eq(count + 1)
        end
      end
      describe 'with invalid_attributes' do
        it 'should fail' do
          count = DiagnosticQuestion.count
          post :create, params: diagnostic_params.merge({ diagnostic_question: valid_question_attributes.merge(body: nil, body_positive: nil) })
          expect(response).to render_template(:new)
          expect(DiagnosticQuestion.count).to eq(count)
        end
      end
    end
    describe 'GET /show' do
      it 'should be successful' do
        get :show, params: diagnostic_params.merge(id: question.id)
        expect(response).to render_template(:show)
      end
    end
    describe 'GET /edit' do
      it 'should be successful' do
        get :edit, params: diagnostic_params.merge(id: question.id)
        expect(response).to render_template(:edit)
      end
    end
    describe 'PUT /update' do
      describe 'with valid attributes' do
        it 'should be successful' do
          put :update, params: diagnostic_params.merge({ id: question.id, diagnostic_question: { body: 'foobar 123' } })
          expect(response).to be_redirect
          question.reload
          expect(question.body).to eq('foobar 123')
        end
      end
      describe 'with invalid attributes' do
        it 'should fail' do
          count = DiagnosticQuestion.count
          put :update, params: diagnostic_params.merge({ id: question.id, diagnostic_question: valid_question_attributes.merge(body: nil, body_positive: nil) })
          expect(response).to render_template(:edit)
          expect(DiagnosticQuestion.count).to eq(count)
        end
      end
    end
    describe 'DELETE /destroy' do
      describe 'if there are translations present' do
        it 'should fail' do
          ApplicationTranslation.create!(
            locale: translations.first.locale,
            key: question.body,
            value: question.body
          )

          count = DiagnosticQuestion.count
          delete :destroy, params: diagnostic_params.merge(id: question.id)
          expect(response).to redirect_to(root_path)
          expect(DiagnosticQuestion.count).to eq(count)
        end
      end
      describe 'if there are no translations present'
      it 'should succeed' do
        count = DiagnosticQuestion.count
        delete :destroy, params: diagnostic_params.merge(id: question.id)
        expect(response).to redirect_to(diagnostic_diagnostic_questions_path(diagnostic_id: team_diagnostic.id))
        expect(DiagnosticQuestion.count).to eq(count - 1)
      end
    end
  end

  describe 'Logged in as Facilitator' do
    before(:each) { sign_in facilitator }

    describe 'GET /index' do
      it 'should fail and redirect' do
        team_diagnostic_questions
        expect do
          get :index, params: diagnostic_params
        end.to raise_error
      end
    end
  end
end
