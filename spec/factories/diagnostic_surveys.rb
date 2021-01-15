# frozen_string_literal: true

# == Schema Information
#
# Table name: diagnostic_surveys
#
#  id                 :uuid             not null, primary key
#  team_diagnostic_id :uuid             not null
#  participant_id     :uuid             not null
#  state              :string           default("pending"), not null
#  locale             :string           default("en"), not null
#  notes              :text
#  last_activity_at   :datetime
#  delivered_at       :datetime
#  started_at         :datetime
#  completed_at       :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
FactoryBot.define do
  factory :diagnostic_survey do
    team_diagnostic { create(:team_diagnostic) }
    participant { create(:participant) }
    state { 'pending' }
    locale { 'en' }
    notes { 'MyText' }
    # last_activity_at { }
    # delivered_at { }
    # started_at { }
    # completed_at { }
  end
end
