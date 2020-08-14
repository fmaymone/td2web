# frozen_string_literal: true

RSpec.shared_context 'roles' do
  let(:admin_role) { create(:role, name: 'Administrator', slug: 'admin') }
  let(:staff_role) { create(:role, name: 'Staff', slug: 'staff') }
  let(:translator_role) { create(:role, name: 'Translator', slug: 'translator') }
  let(:facilitator_role) { create(:role, name: 'Facilitator', slug: 'facilitator') }
  let(:member_role) { create(:role, name: 'Member', slug: 'member') }

  before do
    admin_role
    staff_role
    translator_role
    facilitator_role
    member_role
  end
end
