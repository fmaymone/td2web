# == Schema Information
#
# Table name: coupons
#
#  id          :uuid             not null, primary key
#  code        :string           not null
#  description :string           not null
#  stackable   :boolean          default(FALSE), not null
#  active      :boolean          default(TRUE), not null
#  start_date  :date
#  end_date    :date
#  discount    :integer          default(0), not null
#  product_id  :uuid             not null
#  owner_id    :uuid
#  owner_type  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Coupon < ApplicationRecord
end
