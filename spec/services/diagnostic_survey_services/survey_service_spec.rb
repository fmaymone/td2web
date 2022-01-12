# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiagnosticSurveyServices::SurveyService do
  include_context 'users'
  include_context 'team_diagnostics'

  before(:each) do
    teamdiagnostic_questions
  end

  let(:diagnostic_survey) { teamdiagnostic_deployed.diagnostic_surveys.first }
  let(:all_questions) { teamdiagnostic_deployed.team_diagnostic_questions.order(question_type: :asc, matrix: :asc) }
  let(:question1) { all_questions.first }
  let(:question2) { all_questions.to_a[1] }
  let(:question3) { all_questions.to_a[2] }
  let(:question4) { all_questions.to_a[3] }
  let(:rating_response) { create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: all_questions.rating.first) }
  let(:open_ended_response) { create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: all_questions.open_ended.first) }
  let(:question1_response1) { create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: question1) }
  let(:question2_response1) { create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: question2) }
  let(:question3_response1) { create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: question3) }
  let(:question4_response1) { create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: question4) }
  let(:all_rating_responses) { all_questions.rating.each { |q| create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: q) } }
  let(:all_open_ended_responses) { all_questions.open_ended.each { |q| create(:diagnostic_response, diagnostic_survey:, team_diagnostic_question: q) } }
  let(:service) { DiagnosticSurveyServices::SurveyService.new(diagnostic_survey:) }
  let(:service_by_id) { DiagnosticSurveyServices::SurveyService.new(diagnostic_survey: diagnostic_survey.id) }

  describe 'initialization' do
    it 'should be done given a diagnostic survey' do
      expect(service.diagnostic_survey).to eq(diagnostic_survey)
    end
    it 'should be done given a diagnostic survey id' do
      expect(service_by_id.diagnostic_survey).to eq(diagnostic_survey)
    end
    it 'should fail when given an invalid argument' do
      expect { DiagnosticSurveyServices::SurveyService.new(diagnostic_survey: nil) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'authorization' do
    it 'should indicate whether the diagnostic survey is active' do
      assert(service.authorized?)
    end

    it 'should return false if the survey is not active' do
      diagnostic_survey.state = 'pending'
      diagnostic_survey.save
      refute(service.authorized?)
    end
  end

  describe 'diagnostic survey state' do
    it 'should return whether the participant has started the survey' do
      refute(service.started?)
      question1_response1
      assert(service.started?)
    end
  end

  describe 'returning the current_question' do
    before(:each) do
      question1_response1
    end
    describe 'when team_diagnostic_question_id is provided in params' do
      let(:service) do
        DiagnosticSurveyServices::SurveyService
          .new(diagnostic_survey:,
               params: { team_diagnostic_question_id: question1.id })
      end
      let(:service_invalid_question) do
        DiagnosticSurveyServices::SurveyService
          .new(diagnostic_survey:,
               params: { team_diagnostic_question_id: 0 })
      end
      describe 'when it doesn\'t exist' do
        it 'should raise a record not found error' do
          expect do
            service_invalid_question.current_question
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
      describe 'when it does exist' do
        it 'should return the selected question' do
          expect(service.current_question).to eq(question1)
        end
      end
    end

    describe 'returning the current question response' do
      let(:service) do
        DiagnosticSurveyServices::SurveyService
          .new(diagnostic_survey:,
               params: { team_diagnostic_question_id: question2.id })
      end
      it 'should return the response' do
        expect(service.current_question_response).to eq(nil)
        question2_response1
        expect(service.current_question_response).to eq(question2_response1.response)
      end
    end
  end

  describe 'when no questions have been answered' do
    describe 'providing the wanted current step' do
      it 'should return "intro"' do
        expect(service.step).to eq(:intro)
      end
    end
  end

  describe 'when some rating questions have been answered' do
    before(:each) do
      rating_response
    end
    describe 'providing the wanted current step' do
      it 'should return "rating"' do
        expect(service.step).to eq(:rating)
      end
    end
  end

  describe 'when all rating and some/no open ended questions have been answered' do
    before(:each) do
      all_rating_responses
    end
    describe 'when some open-ended responses have been answered' do
      before(:each) do
        open_ended_response
      end
      describe 'providing the wanted current step' do
        it 'should return "open-ended"' do
          expect(service.step).to eq(:open_ended)
        end
      end
    end
  end

  describe 'when all questions have been answered' do
    describe 'providing the wanted current step' do
      it 'should return "conclusion"' do
        all_rating_responses
        all_open_ended_responses
        expect(service.step).to eq(:conclusion)
      end
    end
  end

  describe 'navigation' do
    let(:service) do
      DiagnosticSurveyServices::SurveyService
        .new(diagnostic_survey:)
    end
    let(:service2) do
      DiagnosticSurveyServices::SurveyService
        .new(diagnostic_survey:,
             params: { team_diagnostic_question_id: question2.id })
    end
    describe 'when there are no answered questions' do
      describe 'returning the next question' do
        it 'should return the next question ' do
          expect(service.current_question).to eq(question1)
          expect(service.next_question).to eq(question2)
        end
      end
      describe 'returning the previous question' do
        it 'should return nil' do
          expect(service.current_question).to eq(question1)
          expect(service.previous_question).to eq(nil)
        end
      end
    end
    describe 'when there are answered questions' do
      describe 'returning the next question' do
        it 'returns the next question' do
          question1_response1
          expect(service2.next_question).to eq(question3)
        end
      end
      describe 'returning the previous question' do
        it 'should return the previous question' do
          question1_response1
          expect(service2.previous_question).to eq(question1)
        end
      end
    end
  end

  describe 'answering a question' do
    describe 'when it has not been answered already' do
      it 'should create a new response for the specified question' do
        answer = 'foobar response'
        locale = 'es'
        question1_response1
        count = DiagnosticResponse.count
        service = DiagnosticSurveyServices::SurveyService.new(
          diagnostic_survey:,
          params: { team_diagnostic_question_id: question2.id, response: answer, locale: }
        )
        expect(service.answer_question).to be_a(DiagnosticResponse)
        expect(DiagnosticResponse.count).to eq(count + 1)
        diagnostic_survey.reload
        last_response = DiagnosticResponse.where(
          diagnostic_survey_id: diagnostic_survey.id,
          team_diagnostic_question_id: question2.id
        ).last
        expect(last_response.response).to eq(answer)
        expect(last_response.locale).to eq(locale)
      end
    end
    describe 'when there is an existing response' do
      it 'should update the response for the specified question' do
        question1_response1
        locale = question1_response1.locale
        answer = "#{question1_response1.response} updated"
        count = DiagnosticResponse.count
        service = DiagnosticSurveyServices::SurveyService.new(
          diagnostic_survey:,
          params: { team_diagnostic_question_id: question1.id, response: answer, locale: }
        )
        expect(service.answer_question).to be_a(DiagnosticResponse)
        expect(DiagnosticResponse.count).to eq(count)
        diagnostic_survey.reload
        last_response = DiagnosticResponse.where(
          diagnostic_survey_id: diagnostic_survey.id,
          team_diagnostic_question_id: question1.id
        ).last
        expect(last_response.id).to eq(question1_response1.id)
        expect(last_response.response).to eq(answer)
      end
    end
  end

  describe 'completion' do
    describe 'when all questions have been answered' do
      it 'should mark the survey as completed and return true' do
        all_rating_responses
        all_open_ended_responses
        assert(diagnostic_survey.active?)
        assert(service.confirm_completion)
        diagnostic_survey.reload
        assert(diagnostic_survey.completed?)
      end
    end

    describe 'when not all questions have been answered' do
      it 'should do nothing and return false' do
        all_rating_responses
        assert(diagnostic_survey.active?)
        refute(service.confirm_completion)
        diagnostic_survey.reload
        refute(diagnostic_survey.completed?)
      end
    end

    describe 'when the survey is not active' do
      it 'should do nothing and return false' do
        all_rating_responses
        diagnostic_survey.cancel!
        refute(service.confirm_completion)
        diagnostic_survey.reload
        refute(diagnostic_survey.completed?)
      end
    end
  end
end
