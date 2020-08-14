# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id          :uuid             not null, primary key
#  slug        :string           not null
#  name        :string           not null
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
RSpec.describe Role, type: :model do
  describe 'initialization' do
    it 'is a Role' do
      expect(Role.new).to be_a(Role)
    end
  end

  describe 'helper class methods' do
    include_context 'roles'

    it 'can reference role records without a finder' do
      assert Role.admin.slug == 'admin'
      assert Role.staff.slug == 'staff'
      assert Role.translator.slug == 'translator'
      assert Role.facilitator.slug == 'facilitator'
      assert Role.member.slug == 'member'
    end
  end
end
