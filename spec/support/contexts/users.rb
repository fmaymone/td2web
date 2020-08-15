# frozen_string_literal: true

RSpec.shared_context 'users', shared_context: :metadate do
  include_context 'roles'
  include_context 'default_tenant'

  let(:admin) do
    create(:user,
           role: admin_role,
           tenant: default_tenant,
           username: 'administrator1',
           email: 'administrator1@example.com',
           password: 'Foobarquux1.',
           password_confirmation: 'Foobarquux1.',
           user_profile_attributes: attributes_for(:user_profile),
           confirmed_at: DateTime.now)
  end
  let(:staff) do
    create(:user,
           role: staff_role,
           tenant: default_tenant,
           username: 'staff1',
           email: 'staff1@example.com',
           password: 'Foobarquux1.',
           password_confirmation: 'Foobarquux1.',
           user_profile_attributes: attributes_for(:user_profile),
           confirmed_at: DateTime.now)
  end
  let(:translator) do
    create(:user,
           role: translator_role,
           tenant: default_tenant,
           username: 'translator1',
           email: 'translator1@example.com',
           password: 'Foobarquux1.',
           password_confirmation: 'Foobarquux1.',
           user_profile_attributes: attributes_for(:user_profile),
           confirmed_at: DateTime.now)
  end
  let(:facilitator) do
    create(:user,
           role: facilitator_role,
           tenant: default_tenant,
           username: 'facilitator1',
           email: 'facilitator1@example.com',
           password: 'Foobarquux1.',
           password_confirmation: 'Foobarquux1.',
           user_profile_attributes: attributes_for(:user_profile),
           confirmed_at: DateTime.now)
  end
  let(:member) do
    create(:user,
           role: member_role,
           tenant: default_tenant,
           username: 'member1',
           email: 'member1@example.com',
           password: 'Foobarquux1.',
           password_confirmation: 'Foobarquux1.',
           user_profile_attributes: attributes_for(:user_profile),
           confirmed_at: DateTime.now)
  end
end
