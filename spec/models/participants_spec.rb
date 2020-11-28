# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Participant, type: :model do
  include_context 'team_diagnostics'

  let(:participant) { create(:participant, team_diagnostic: teamdiagnostic) }

  describe 'initialization' do
    it 'can be initialized' do
      assert(participant.valid?)
    end
  end

  describe 'validation' do
    it 'should require an email address' do
      participant.email = nil
      refute participant.valid?
    end
    it 'should require name information' do
      assert participant.valid?
      old_first_name = participant.first_name
      participant.first_name = nil
      refute participant.valid?
      participant.first_name = old_first_name
      participant.last_name = nil
      refute participant.valid?
    end
    it 'should require locale information' do
      assert participant.valid?
      old_locale = participant.locale
      participant.locale = nil
      refute participant.valid?
      participant.locale = old_locale
      participant.timezone = nil
      refute participant.valid?
    end
  end

  describe 'state machine' do
    it 'should have a first state of "approved"' do
      p = Participant.new
      expect(p.state).to eq('approved')
    end
  end
end
