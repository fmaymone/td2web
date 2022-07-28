# == Schema Information
#
# Table name: products
#
#  id                 :uuid             not null, primary key
#  product_type       :integer          default("standalone"), not null
#  slug               :string           not null
#  name               :string           not null
#  description        :text
#  price              :decimal(, )      default(0.0), not null
#  volume_pricing     :jsonb            not null
#  entitlement_detail :jsonb            not null
#  active             :boolean          default(TRUE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class Product < ApplicationRecord
  enum product_type: [:standalone, :addon]
end
