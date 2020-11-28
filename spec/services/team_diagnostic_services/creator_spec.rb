# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamDiagnosticServices::Creator do
  include_context 'users'
  include_context 'organizations'
  include_context 'diagnostics'

  let(:valid_params) { attributes_for(:team_diagnostic, user: facilitator, organization: organization, diagnostic: team_diagnostic) }
  let(:invalid_params) { valid_params.merge(diagnostic_id: nil, name: nil) }

  describe 'initialization' do
    it 'succeeds' do
      service = TeamDiagnosticServices::Creator.new(user: facilitator, params: valid_params)
      assert(service)
    end

    describe 'with invalid attributes' do
      describe 'with required grants' do
        it 'fails to create a new TeamDiagnostic' do
          count = TeamDiagnostic.count
          user_count = facilitator.team_diagnostics.count
          service = TeamDiagnosticServices::Creator.new(user: facilitator, params: invalid_params)
          refute(service.call)
          expect(TeamDiagnostic.count).to eq(count)
          expect(facilitator.team_diagnostics.count).to eq(user_count)
        end
      end
    end

    describe 'with valid attributes' do
      describe 'with required grants' do
        it 'creates a new TeamDiagnostic' do
          count = TeamDiagnostic.count
          user_count = facilitator.team_diagnostics.count
          service = TeamDiagnosticServices::Creator.new(user: facilitator, params: valid_params)
          assert(service.call)
          expect(TeamDiagnostic.count).to eq(count + 1)
          expect(facilitator.team_diagnostics.count).to eq(user_count + 1)
        end
      end
      describe 'without required grants' do
        it 'does not create a teamdiagnostic' do
          facilitator.grants.destroy_all
          count = TeamDiagnostic.count
          user_count = facilitator.team_diagnostics.count
          service = TeamDiagnosticServices::Creator.new(user: facilitator, params: valid_params)
          service.call
          refute(service.call)
          expect(TeamDiagnostic.count).to eq(count)
          expect(facilitator.team_diagnostics.count).to eq(user_count)
        end
      end
    end
  end
end
