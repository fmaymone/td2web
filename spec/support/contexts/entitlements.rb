# frozen_string_literal: true

RSpec.shared_context 'entitlements', shared_context: :metadate do
  include_context 'default_tenant'
  include_context 'roles'

  let(:registration_entitlement) do
    Entitlement.create!(
      active: true,
      account: false,
      role: facilitator_role,
      reference: 'Users::Registrations#',
      slug: 'register-facilitator',
      quota: 1,
      description: 'Register as an Teamdiagnostic facilitator'
    )
  end

  let(:entitlement_for_admins) { create(:entitlement, role: admin_role) }

  let(:entitlement_for_staff) { create(:entitlement, role: staff_role) }
  let(:entitlement_for_staff2) { create(:entitlement, role: staff_role) }
  let(:entitlement_for_facilitators) { create(:entitlement, role: facilitator_role) }
  let(:entitlement_for_facilitators2) { create(:entitlement, role: facilitator_role) }
end
