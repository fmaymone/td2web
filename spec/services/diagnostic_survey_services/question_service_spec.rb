# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosticSurveyServices::QuestionService do
  include_context 'users'
  include_context 'team_diagnostics'

  let(:diagnostic_survey) { teamdiagnostic_deployed.diagnostic_surveys.first }
  let(:all_questions) { teamdiagnostic_deployed.team_diagnostic_questions.order(matrix: :asc).to_a }
  let(:question1) { all_questions.first }
  let(:question2) { all_questions[1] }
  let(:question3) { all_questions[2] }
  let(:question4) { all_questions[3] }
  let(:question1_response1) { create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: question1) }
  let(:question2_response1) { create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: question2) }
  let(:question3_response1) { create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: question3) }
  let(:question4_response1) { create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: question4) }

  describe 'initialization' do
    let(:service) { DiagnosticSurveyServices::QuestionService.new(diagnostic_survey:) }

    it 'should initialize' do
      service
      expect(service.diagnostic_survey).to eq(diagnostic_survey)
    end
  end

  describe 'question helpers' do
    let(:service) { DiagnosticSurveyServices::QuestionService.new(diagnostic_survey:) }

    it 'should list all questions' do
      expect(service.all_questions.pluck(:id).sort).to eq(diagnostic_survey.questions.pluck(:id).sort)
    end

    describe 'when no questions have been answered' do
      it 'should return the last answered question' do
        expect(service.last_answered_question).to eq(nil)
      end

      it 'should return the first question as the current question' do
        expect(service.current_question).to eq(service.all_questions.first)
      end

      it 'should return nil as the last answered question' do
        expect(service.previous_question).to eq(nil)
      end
    end

    describe 'when questions have been answered' do
      it 'should return the last answered question' do
        question1_response1
        expect(service.last_answered_question).to eq(question1)
        question2_response1
        expect(service.last_answered_question).to eq(question2)
      end
      it 'should return the current question' do
        question1_response1
        question2_response1
        expect(service.current_question).to eq(question3)
      end
      it 'should return the previously answered question' do
        question1_response1
        question2_response1
        question3_response1
        expect(service.previous_question).to eq(question3)
      end
      it 'should return the given question\'s response' do
        question1_response1
        question2_response1
        question3_response1
        expect(service.question_response(question2)).to eq(question2_response1.response)
      end

      it 'should return the next question' do
        expect(service.next_question).to eq(question2)
        question1_response1
        expect(service.next_question).to eq(question3)
        question_count = all_questions.count
        all_questions[0..(question_count - 3)].each do |q|
          create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: q)
        rescue StandardError
          nil
        end
        expect(service.next_question).to eq(all_questions.last)
        all_questions.each do |q|
          create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: q)
        rescue StandardError
          nil
        end
        expect(service.next_question).to eq(nil)
      end

      describe 'when a question was skipped between answers' do
        it 'the current_question returns the first unanswered question' do
          question1_response1
          question3_response1
          expect(service.current_question).to eq(question2)
        end
      end
    end

    describe 'when all questions have been answered' do
      let(:all_questions) { teamdiagnostic_deployed.team_diagnostic_questions.order(matrix: :asc).to_a }
      before do
        all_questions.each { |q| create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: q) }
      end

      it 'should return the last question for previous_question' do
        expect(service.previous_question).to eq(all_questions.last)
      end
    end

    describe 'answering a question' do
      let(:new_response) { 'question1 response' }
      describe 'which has not yet been answered' do
        it 'should create a new question response' do
          response_count = DiagnosticResponse.count

          service.answer_question(question: question1, response: new_response)
          expect(DiagnosticResponse.count).to eq(response_count + 1)
          expect(service.question_response(question1)).to eq(new_response)
        end
      end
      describe 'updating an existing response' do
        it 'should update the given question response' do
          question1_response1
          response_count = DiagnosticResponse.count
          service.answer_question(question: question1, response: new_response)
          expect(DiagnosticResponse.count).to eq(response_count)
          question1_response1.reload
          expect(question1_response1.response).to eq(new_response)
        end
      end
    end
  end
end
