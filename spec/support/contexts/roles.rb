# frozen_string_literal: true

RSpec.shared_context 'roles', shared_context: :metadate do
  let(:admin_role) { Role.admin || create(:role, name: 'Administrator', slug: 'admin') }
  let(:staff_role) { Role.staff || create(:role, name: 'Staff', slug: 'staff') }
  let(:translator_role) { Role.translator || create(:role, name: 'Translator', slug: 'translator') }
  let(:facilitator_role) { Role.facilitator || create(:role, name: 'Facilitator', slug: 'facilitator') }
  let(:member_role) { Role.member || create(:role, name: 'Member', slug: 'member') }

  before do
    admin_role
    staff_role
    translator_role
    facilitator_role
    member_role
  end
end
