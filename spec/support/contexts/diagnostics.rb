# frozen_string_literal: true

require_relative '../../../db/seed/diagnostics'
require_relative '../../../db/seed/diagnostic_questions'

RSpec.shared_context 'diagnostics', shared_context: :metadate do
  let(:diagnostic_question_seed_data_filepath) { File.join(Rails.root, 'db', 'seed', 'diagnostic_questions_for_test.csv') }
  let(:diagnostic_seed_data) { Seeds::Diagnostics.new.call }
  let(:diagnostic_question_seed_data) { Seeds::DiagnosticQuestions.new(filename: diagnostic_question_seed_data_filepath).call }

  let(:team_diagnostic) do
    diagnostic_seed_data
    diagnostic_question_seed_data
    Diagnostic.where(slug: Diagnostic::TDA_SLUG).first
  end

  let(:team_leader_diagnostic) do
    diagnostic_seed_data
    Diagnostic.where(slug: Diagnostic::TLV_SLUG).first
  end

  let(:team_360_diagnostic) do
    diagnostic_seed_data
    Diagnostic.where(slug: Diagnostic::T360_SLUG).first
  end

  let(:organization_diagnostic) do
    diagnostic_seed_data
    Diagnostic.where(slug: Diagnostic::ORG_SLUG).first
  end

  let(:leadership_360_diagnostic) do
    diagnostic_seed_data
    Diagnostic.where(slug: Diagnostic::L360_SLUG).first
  end

  let(:family_tribes_diagnostic) do
    diagnostic_seed_data
    Diagnostic.where(slug: Diagnostic::FAMILY_TRIBES_SLUG).first
  end
end
