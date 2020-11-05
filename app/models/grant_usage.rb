# frozen_string_literal: true

# == Schema Information
#
# Table name: grant_usages
#
#  id         :uuid             not null, primary key
#  grant_id   :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class GrantUsage < ApplicationRecord
  belongs_to :grant
end
