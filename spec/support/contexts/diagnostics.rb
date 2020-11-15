# frozen_string_literal: true

require_relative '../../../db/seed/diagnostics'

RSpec.shared_context 'diagnostics', shared_context: :metadate do
  let(:diagnostic_seed_data) { Seeds::Diagnostics.new.call }

  let(:team_diagnostic) do
    diagnostic_seed_data
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
end
