# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamDiagnosticServices::Updater do
  include_context 'users'
  include_context 'organizations'
  include_context 'diagnostics'

  let(:team_diagnostic) { create(:team_diagnostic, user: facilitator, organization:) }
  let(:team_diagnostic2) { create(:team_diagnostic, user: facilitator2, organization: organization2) }
  let(:new_description) { "#{team_diagnostic.description}foobar" }
  let(:valid_params) { { description: new_description } }
  let(:invalid_params) { valid_params.merge(name: nil, description: new_description) }

  describe 'initialization' do
    it 'succeeds' do
      service = TeamDiagnosticServices::Updater.new(user: facilitator, id: team_diagnostic.id, params: {})
      assert(service)
    end

    describe 'with invalid attributes' do
      it 'fails to update the TeamDiagnostic' do
        service = TeamDiagnosticServices::Updater.new(user: facilitator, id: team_diagnostic.id, params: invalid_params)
        refute(service.call)
        team_diagnostic.reload
        expect(team_diagnostic.description).to_not eq(new_description)
      end
    end

    describe 'with valid attributes' do
      it 'updates the TeamDiagnostic' do
        service = TeamDiagnosticServices::Updater.new(user: facilitator, id: team_diagnostic.id, params: valid_params)
        assert(service.call)
        team_diagnostic.reload
        expect(team_diagnostic.description).to eq(new_description)
      end
    end
  end
end
