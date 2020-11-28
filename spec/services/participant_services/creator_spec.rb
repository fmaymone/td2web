# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ParticipantServices::Creator do
  include_context 'users'
  include_context 'team_diagnostics'
  include_context 'participants'

  let(:service_class) { ParticipantServices::Creator }
  let(:user) { facilitator }
  let(:diagnostic) { teamdiagnostic }
  let(:valid_attributes) do
    {
      title: 'Mr.',
      first_name: 'Wol',
      last_name: 'Smoth',
      locale: 'en',
      timezone: 'UTC',
      email: 'wol.smoth@example.com'
    }
  end
  let(:invalid_attributes) { valid_attributes.merge(email: nil) }

  describe 'initialization' do
    it 'can be initialized' do
      service = service_class.new(
        user: user,
        team_diagnostic: diagnostic,
        params: {}
      )
      assert(service.is_a?(service_class))
    end
  end

  describe 'as a facilitator' do
    describe 'with valid attributes' do
      it 'creates a new participant' do
        count = Participant.count
        service = service_class.new(
          user: user,
          team_diagnostic: diagnostic,
          params: valid_attributes
        )
        assert(service.call)
        assert(service.errors.empty?)
        assert(service.participant.valid?)
        expect(Participant.count).to eq(count + 1)
      end
    end

    describe 'with invalid attributes' do
      it 'fails to create a participant' do
        count = Participant.count
        service = service_class.new(
          user: user,
          team_diagnostic: diagnostic,
          params: invalid_attributes
        )
        refute(service.call)
        refute(service.errors.empty?)
        refute(service.participant.valid?)
        expect(Participant.count).to eq(count)
      end
    end
  end
end
