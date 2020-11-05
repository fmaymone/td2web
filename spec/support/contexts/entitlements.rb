# frozen_string_literal: true

require_relative '../../../db/seed/entitlements'

RSpec.shared_context 'entitlements', shared_context: :metadate do
  let(:entitlement_seed_data) { Seeds::Entitlements.new.call }

  let(:registration_entitlement) do
    entitlement_seed_data
    Entitlement.where(slug: Entitlement::REGISTER_AS_FACILITATOR).first
  end

  let(:create_organization_entitlement) do
    entitlement_seed_data
    Entitlement.where(slug: Entitlement::CREATE_ORGANIZATION).first
  end

  let(:entitlement_for_admins) { create(:entitlement, role: admin_role) }

  let(:entitlement_for_staff) { create(:entitlement, role: staff_role) }
  let(:entitlement_for_staff2) { create(:entitlement, role: staff_role) }
  let(:entitlement_for_facilitators) { create(:entitlement, role: facilitator_role) }
  let(:entitlement_for_facilitators2) { create(:entitlement, role: facilitator_role) }
end
