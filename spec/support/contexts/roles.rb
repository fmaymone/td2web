# frozen_string_literal: true

RSpec.shared_context 'roles', shared_context: :metadate do
  let(:admin_role) { Role.admin || create(:role, name: 'Administrator', slug: Role::ADMIN_ROLE) }
  let(:staff_role) { Role.staff || create(:role, name: 'Staff', slug: Role::STAFF_ROLE) }
  let(:translator_role) { Role.translator || create(:role, name: 'Translator', slug: Role::TRANSLATOR_ROLE) }
  let(:facilitator_role) { Role.facilitator || create(:role, name: 'Facilitator', slug: Role::FACILITATOR_ROLE) }
  let(:member_role) { Role.member || create(:role, name: 'Member', slug: Role::MEMBER_ROLE) }

  before do
    admin_role
    staff_role
    translator_role
    facilitator_role
    member_role
  end
end
