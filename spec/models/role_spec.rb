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

require 'rails_helper'

RSpec.describe Role, type: :model do
  include_context 'roles'

  describe 'initialization' do
    it 'is a Role' do
      expect(Role.new).to be_a(Role)
    end
  end

  describe 'helper class methods' do
    it 'can reference role records without a finder' do
      assert Role.admin.slug == 'admin'
      assert Role.staff.slug == 'staff'
      assert Role.translator.slug == 'translator'
      assert Role.facilitator.slug == 'facilitator'
      assert Role.member.slug == 'member'
    end
  end

  describe 'comparison' do
    it 'compares roles' do
      assert admin_role > staff_role
      assert admin_role > translator_role
      assert admin_role > facilitator_role
      assert admin_role > member_role
    end
  end
end
