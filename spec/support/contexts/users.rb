# frozen_string_literal: true

RSpec.shared_context 'users', shared_context: :metadate do
  include_context 'default_tenant'
  include_context 'roles'
  include_context 'grants'
  include_context 'entitlements'

  let(:admin) do
    user = build(:user,
                 role: admin_role,
                 tenant: default_tenant,
                 username: 'administrator1',
                 email: 'administrator1@example.com',
                 password: 'Foobarquux1.',
                 password_confirmation: 'Foobarquux1.',
                 user_profile_attributes: attributes_for(:user_profile),
                 confirmed_at: DateTime.now)
    user.save!
    user
  end
  let(:staff) do
    user = build(:user,
                 role: staff_role,
                 tenant: default_tenant,
                 username: 'staff1',
                 email: 'staff1@example.com',
                 password: 'Foobarquux1.',
                 password_confirmation: 'Foobarquux1.',
                 user_profile_attributes: attributes_for(:user_profile),
                 confirmed_at: DateTime.now)
    user.save!
    user
  end
  let(:translator) do
    user = build(:user,
                 role: translator_role,
                 tenant: default_tenant,
                 username: 'translator1',
                 email: 'translator1@example.com',
                 password: 'Foobarquux1.',
                 password_confirmation: 'Foobarquux1.',
                 user_profile_attributes: attributes_for(:user_profile),
                 confirmed_at: DateTime.now)
    user.save!
    user
  end
  let(:facilitator) do
    user = build(:user,
                 role: facilitator_role,
                 tenant: default_tenant,
                 username: 'facilitator1',
                 email: 'facilitator1@example.com',
                 password: 'Foobarquux1.',
                 password_confirmation: 'Foobarquux1.',
                 user_profile_attributes: attributes_for(:user_profile),
                 confirmed_at: DateTime.now)
    user.save!
    create(:grant, user: user, grantor: admin, reference: OrganizationServices::Creator::REFERENCE, entitlement: create_organization_entitlement, quota: 3)
    user
  end
  let(:facilitator2) do
    user = build(:user,
                 role: facilitator_role,
                 tenant: default_tenant,
                 username: 'facilitator2',
                 email: 'facilitator2@example.com',
                 password: 'Foobarquux1.',
                 password_confirmation: 'Foobarquux1.',
                 user_profile_attributes: attributes_for(:user_profile),
                 confirmed_at: DateTime.now)
    user.save!
    create(:grant, user: user, grantor: admin, reference: OrganizationServices::Creator::REFERENCE, entitlement: create_organization_entitlement, quota: 3)
    user
  end
  let(:member) do
    user = build(:user,
                 role: member_role,
                 tenant: default_tenant,
                 username: 'member1',
                 email: 'member1@example.com',
                 password: 'Foobarquux1.',
                 password_confirmation: 'Foobarquux1.',
                 user_profile_attributes: attributes_for(:user_profile),
                 confirmed_at: DateTime.now)
    user.save!
    user
  end

  let(:full_featured_user) do
    user = build(:user,
                 role: facilitator_role,
                 tenant: default_tenant,
                 username: 'facilitator1',
                 email: 'facilitator1@example.com',
                 password: 'Foobarquux1.',
                 password_confirmation: 'Foobarquux1.',
                 user_profile_attributes: attributes_for(:user_profile),
                 confirmed_at: DateTime.now)
    user.save!
    create(:grant, user: user, grantor: admin, entitlement: entitlement)
    user.reload
    user
  end
end
