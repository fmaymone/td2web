# frozen_string_literal: true

# Model representing usage of a grant
class GrantUsage < ApplicationRecord
  belongs_to :grant
end
