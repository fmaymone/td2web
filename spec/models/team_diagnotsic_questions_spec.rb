# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamDiagnosticQuestion, type: :model do
  include_context 'team_diagnostics'

  let(:team_diagnostic_question) { create(:team_diagnostic_question, team_diagnostic: teamdiagnostic) }

  describe 'initialization' do
    it 'can be initialized' do
      assert(team_diagnostic_question.valid?)
    end
  end

  describe 'validations' do
    it 'has a unique body within a team diagnostic' do
      team_diagnostic_question
      dupe = build(:team_diagnostic_question, team_diagnostic: teamdiagnostic)
      assert(dupe.valid?)
      dupe.body = team_diagnostic_question.body
      refute(dupe.valid?)
    end
  end

  describe 'new from a Diagnostic Question' do
    before(:each) do
      diagnostic_seed_data
      diagnostic_question_seed_data
    end

    it 'initializes a new unsaved TeamDiagnosticQuestion' do
      dq = teamdiagnostic.diagnostic.diagnostic_questions.open_ended.first
      tdq = TeamDiagnosticQuestion.from_diagnostic_question(dq).first
      tdq.team_diagnostic = teamdiagnostic
      assert(tdq.valid?)

      tdq = TeamDiagnosticQuestion.new({ body: 'Foobar' })
      tdq.team_diagnostic = teamdiagnostic
      assert(tdq.valid?)
    end
  end
end
