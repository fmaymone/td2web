# frozen_string_literal: true

RSpec.shared_context 'invitations', shared_context: :metadate do
  include_context 'users'
  include_context 'entitlements'
  include_context 'default_tenant'

  let(:registration_invitation) do
    invitation = Invitation.new(
      email: 'me@here.com',
      i18n_key: 'invitation-message-register-facilitator',
      description: 'Test invitation',
      redirect: '/auth/sign_up',
      entitlements: [{ id: registration_entitlement.id, quota: 1 }]
    )
    invitation.tenant = default_tenant
    invitation.grantor = staff
    invitation.save!
    invitation
  end

  let(:facilitator_feature_invitation) do
    invitation = Invitation.new(
      email: 'me@here.com',
      i18n_key: 'invitation-message-facilitator-feature',
      description: 'Test invitation',
      redirect: '/',
      entitlements: [
        { id: entitlement_for_facilitators.id, quota: 42 },
        { id: entitlement_for_facilitators2.id, quota: 21 }
      ]
    )
    invitation.tenant = default_tenant
    invitation.grantor = staff
    invitation.save!
    invitation
  end

  before(:each) do
    admin
  end
end
