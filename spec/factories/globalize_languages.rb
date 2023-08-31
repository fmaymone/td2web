# frozen_string_literal: true

# == Schema Information
#
# Table name: globalize_languages
#
#  id                    :bigint           not null, primary key
#  iso_639_1             :string(2)
#  iso_639_2             :string(3)
#  iso_639_3             :string(3)
#  rfc_3066              :string(255)
#  english_name          :string(255)
#  english_name_locale   :string(255)
#  english_name_modifier :string(255)
#  native_name           :string(255)
#  native_name_locale    :string(255)
#  native_name_modifier  :string(255)
#  macro_language        :boolean
#  direction             :string(255)
#  pluralization         :string(255)
#  scope                 :string(1)
#
FactoryBot.define do
  factory :globalize_language do
    sequence(:id, &:to_i)
    sequence(:english_name, &:to_s)
    sequence(:iso_639_1, &:to_s)
    sequence(:iso_639_2, &:to_s)
    sequence(:iso_639_3, &:to_s)
  end
end
