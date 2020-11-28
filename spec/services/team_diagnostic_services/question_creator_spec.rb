# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamDiagnosticServices::QuestionCreator do
  include_context 'users'
  include_context 'organizations'
  include_context 'diagnostics'
  include_context 'team_diagnostics'

  let(:diagnostic_question) { teamdiagnostic.diagnostic.diagnostic_questions.open_ended.first }
  let(:valid_params_for_new_eoq) { { body: 'Custom OEQ #1' } }
  let(:valid_params_for_diagnostic_question) { { diagnostic_question_id: diagnostic_question.id } }

  describe 'initialization' do
    describe 'as a new Open Ended Question' do
      it 'can be created with a TeamDiagnostic, User, and body' do
        service = TeamDiagnosticServices::QuestionCreator.new(
          team_diagnostic: teamdiagnostic,
          user: teamdiagnostic.user,
          params: valid_params_for_new_eoq
        )
        expect(service.team_diagnostic).to eq(teamdiagnostic)
        assert(service.team_diagnostic_question.valid?)
        new_tdq = service.call
        expect(new_tdq).to be_a(TeamDiagnosticQuestion)
        teamdiagnostic.reload
        expect(teamdiagnostic.questions.to_a).to eq([new_tdq])
      end
    end
    describe 'as a copy of a DiagnosticQuestion' do
      it 'can be initialized with a TeamDiagnostic, User, and reference to Diagnostic Question' do
        service = TeamDiagnosticServices::QuestionCreator.new(
          team_diagnostic: teamdiagnostic,
          user: teamdiagnostic.user,
          params: valid_params_for_diagnostic_question
        )
        expect(service.team_diagnostic).to eq(teamdiagnostic)
        assert(service.team_diagnostic_question.valid?)
        new_tdq = service.call
        expect(new_tdq).to be_a(TeamDiagnosticQuestion)
        teamdiagnostic.reload
        expect(teamdiagnostic.questions.to_a).to eq([new_tdq])
      end
    end
  end
end
