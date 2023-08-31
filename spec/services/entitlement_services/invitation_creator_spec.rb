# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EntitlementServices::InvitationCreator do
  include_context 'users'

  let(:grantor) { facilitator }
  let(:entitlements) { [create(:entitlement, role: grantor.role), create(:entitlement, role: grantor.role)] }
  let(:entitlement_options) { entitlements.map { |e| { id: e.id, quota: 5, slug: e.slug } } }
  let(:invitation_message_translation) { ApplicationTranslation.new(locale: 'en', key: "invitation-message-#{entitlements.first.slug}", value: 'Foobar') }
  let(:invitation_message_subject_translation) { ApplicationTranslation.new(locale: 'en', key: 'invitation-message-subject', value: 'Foobar') }
  let(:sample_email) { Faker::Internet.email }
  let(:sample_invitation_role) { :facilitator }
  let(:sample) do
    EntitlementServices::InvitationCreator.new(
      grantor:,
      params: {
        email: sample_email,
        description: 'Test invitation',
        entitlements: entitlement_options,
        i18n_key: invitation_message_translation.key
      },
      role: sample_invitation_role
    )
  end
  let(:invalid_sample) do
    EntitlementServices::InvitationCreator.new(
      grantor:,
      params: {
        email: nil,
        description: nil,
        entitlements: entitlement_options,
        i18n_key: invitation_message_translation.key
      },
      role: sample_invitation_role
    )
  end

  before(:each) do
    invitation_message_translation
    invitation_message_subject_translation
  end

  describe 'Initialize' do
    it 'should be setup' do
      sample
    end
  end

  describe 'Creating an Invitation for a facilitator' do
    describe 'with valid attributes' do
      it 'should create an invitation' do
        count = Invitation.count
        invitation = sample.call
        assert(invitation.valid?)
        expect(sample.errors).to be_empty
        expect(Invitation.count).to eq(count + 1)
        expect(invitation.grantor).to eq(grantor)
        expect(invitation.email).to eq(sample_email)
        expect(invitation.tenant).to eq(grantor.tenant)
        expect(invitation.entitlements.map{|e| e.fetch(:slug)}).to eq(EntitlementServices::InvitationCreator::DEFAULT_FACILITATOR_ENTITLEMENTS)
      end
    end

    describe 'with invalid attributes' do
      it 'should not create an invitation' do
        count = Invitation.count
        invitation = invalid_sample.call
        refute(invitation.valid?)
        expect(invalid_sample.errors).to_not be_empty
        expect(Invitation.count).to eq(count)
      end
    end
  end
end
