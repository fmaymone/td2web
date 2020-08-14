# frozen_string_literal: true

# == Schema Information
#
# Table name: translations
#
#  id             :bigint           not null, primary key
#  locale         :string           not null
#  key            :string           not null
#  value          :text             not null
#  interpolations :text
#  is_proc        :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
FactoryBot.define do
  factory :translation do
    locale { create(:globalize_language).locale }
    sequence :key do |n|
      Faker::Alphanumeric.alpha(number: 5) + "-#{n}"
    end
    value { Faker::Lorem.sentence }
  end
end
