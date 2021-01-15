# frozen_string_literal: true

# == Schema Information
#
# Table name: team_diagnostic_letters
#
#  id                 :uuid             not null, primary key
#  team_diagnostic_id :uuid
#  letter_type        :integer
#  locale             :string           default("en")
#  subject            :string
#  body               :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
FactoryBot.define do
  factory :team_diagnostic_letter do
    team_diagnostic { create(:team_diagnostic) }
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.sentence }
    locale { team_diagnostic.locale }
  end
end
