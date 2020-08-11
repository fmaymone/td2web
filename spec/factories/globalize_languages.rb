# frozen_string_literal: true

FactoryBot.define do
  factory :globalize_language do
    sequence(:english_name, &:to_s)
    sequence(:iso_639_1, &:to_s)
    sequence(:iso_639_2, &:to_s)
    sequence(:iso_639_3, &:to_s)
  end
end
