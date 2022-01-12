# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ParticipantServices::Updater do
  include_context 'users'
  include_context 'team_diagnostics'
  include_context 'participants'

  let(:service_class) { ParticipantServices::Updater }
  let(:user) { facilitator }
  let(:diagnostic) { teamdiagnostic }
  let(:valid_attributes) do
    {
      title: 'Mr.',
      first_name: 'Wol',
      last_name: 'Smothzzzz',
      locale: 'en',
      timezone: 'UTC',
      email: 'wol.smoth@example.com'
    }
  end
  let(:invalid_attributes) { valid_attributes.merge(last_name: 'foobar', email: nil) }

  describe 'initialization' do
    it 'can be initialized' do
      service = service_class.new(user:, id: participant.id, params: valid_attributes)
      expect(service).to be_a(service_class)
    end
  end

  describe 'calling the service' do
    describe 'with valid attributes' do
      it 'updates the application record' do
        service = service_class.new(user:, id: participant.id, params: valid_attributes)
        updated_participant = service.call
        expect(updated_participant).to be_a(Participant)
        participant.reload
        expect(participant.last_name).to eq(valid_attributes[:last_name])
      end
    end

    describe 'with invalid attributes' do
      it 'fails to update the application record' do
        service = service_class.new(user:, id: participant.id, params: invalid_attributes)
        refute(service.call)
        refute(service.valid?)
        participant.reload
        expect(participant.last_name).to_not eq(invalid_attributes[:last_name])
      end
    end
  end

  describe 'disqualifying the participant' do
    it 'should disqualify a participant' do
      assert(participant.approved?)
      service = service_class.new(user:, id: participant.id, params: invalid_attributes)
      service.disqualify!
      participant.reload
      assert(participant.disqualified?)
    end
  end
end
