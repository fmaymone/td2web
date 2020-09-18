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
class GlobalizeLanguage < ApplicationRecord
  ### Concerns

  ### Validations
  validates :english_name, presence: true, uniqueness: { case_sensitive: false }
  validates :iso_639_1, presence: true, uniqueness: { case_sensitive: false }
  validates :iso_639_2, presence: true, uniqueness: { case_sensitive: false }
  validates :iso_639_3, presence: true, uniqueness: { case_sensitive: false }

  def locale
    iso_639_1
  end
end
