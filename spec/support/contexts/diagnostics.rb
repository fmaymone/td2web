# frozen_string_literal: true

require_relative '../../../db/seed/diagnostics'
require_relative '../../../db/seed/diagnostic_questions'
require_relative '../../../db/seed/report_templates'

RSpec.shared_context 'diagnostics', shared_context: :metadate do
  let(:diagnostic_question_seed_data_filepath) { File.join(Rails.root, 'db', 'seed', 'diagnostic_questions_for_test.csv') }
  let(:diagnostic_seed_data) { Seeds::Diagnostics.new.call }
  let(:diagnostic_question_seed_data) { Seeds::DiagnosticQuestions.new(filename: diagnostic_question_seed_data_filepath).call }
  let(:completed_diagnostic_question_seed_data_filepath) { File.join(Rails.root, 'db', 'seed', 'diagnostic_questions_for_test.csv') }
  let(:completed_diagnostic_question_seed_data) { Seeds::DiagnosticQuestions.new(filename: completed_diagnostic_question_seed_data_filepath).call }
  let(:report_templates_seed_data_filepath) do
    File.join(Rails.root, 'db', 'seed', 'report_templates_for_test.yml')
  end
  let(:report_templates_seed_data) { Seeds::ReportTemplates.new(filename: report_templates_seed_data_filepath).call }

  let(:team_diagnostic_for_completed_diagnostic) do
    diagnostic_seed_data
    completed_diagnostic_question_seed_data
    Diagnostic.where(slug: Diagnostic::TDA_SLUG).first
  end

  let(:tda_diagnostic) do
    diagnostic_seed_data
    diagnostic_question_seed_data
    report_templates_seed_data
    Diagnostic.where(slug: Diagnostic::TDA_SLUG).first
  end

  let(:team_leader_diagnostic) do
    diagnostic_seed_data
    report_templates_seed_data
    Diagnostic.where(slug: Diagnostic::TLV_SLUG).first
  end

  let(:team_360_diagnostic) do
    diagnostic_seed_data
    report_templates_seed_data
    Diagnostic.where(slug: Diagnostic::T360_SLUG).first
  end

  let(:organization_diagnostic) do
    diagnostic_seed_data
    report_templates_seed_data
    Diagnostic.where(slug: Diagnostic::ORG_SLUG).first
  end

  let(:leadership_360_diagnostic) do
    diagnostic_seed_data
    report_templates_seed_data
    Diagnostic.where(slug: Diagnostic::L360_SLUG).first
  end

  let(:family_tribes_diagnostic) do
    diagnostic_seed_data
    report_templates_seed_data
    Diagnostic.where(slug: Diagnostic::FAMILY_TRIBES_SLUG).first
  end
end
