# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosticSurveyServices::QuestionService do
  include_context 'users'
  include_context 'team_diagnostics'

  let(:diagnostic_survey) { teamdiagnostic_deployed.diagnostic_surveys.first }

  describe 'initialization' do
    let(:service) { DiagnosticSurveyServices::QuestionService.new(diagnostic_survey: diagnostic_survey) }

    it 'should initialize' do
      service
      expect(service.diagnostic_survey).to eq(diagnostic_survey)
    end
  end

  describe 'question helpers' do
    let(:service) { DiagnosticSurveyServices::QuestionService.new(diagnostic_survey: diagnostic_survey) }

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
      let(:all_questions) { teamdiagnostic_deployed.team_diagnostic_questions.order(matrix: :asc).to_a }
      let(:question1) { all_questions.first }
      let(:question2) { all_questions[1] }
      let(:question3) { all_questions[2] }
      let(:question4) { all_questions[4] }
      let(:question1_response1) { create(:diagnostic_response, diagnostic_survey: diagnostic_survey, team_diagnostic_question: question1) }
      let(:question2_response1) { create(:diagnostic_response, diagnostic_survey: diagnostic_survey, team_diagnostic_question: question2) }
      let(:question3_response1) { create(:diagnostic_response, diagnostic_survey: diagnostic_survey, team_diagnostic_question: question3) }
      let(:question4_response1) { create(:diagnostic_response, diagnostic_survey: diagnostic_survey, team_diagnostic_question: question4) }

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
        all_questions.each { |q| create(:diagnostic_response, diagnostic_survey: diagnostic_survey, team_diagnostic_question: q) }
      end

      it 'should return the last question for previous_question' do
        expect(service.previous_question).to eq(all_questions.last)
      end
    end
  end
end
