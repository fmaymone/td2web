# frozen_string_literal: true

# == Schema Information
#
# Table name: globalize_countries
#
#  id                     :bigint           not null, primary key
#  code                   :string(2)
#  english_name           :string(255)
#  date_format            :string(255)
#  currency_format        :string(255)
#  currency_code          :string(3)
#  thousands_sep          :string(2)
#  decimal_sep            :string(2)
#  currency_decimal_sep   :string(2)
#  number_grouping_scheme :string(255)
#
# Country Records
class GlobalizeCountry < ApplicationRecord
  ### Concerns
  audited

  ### Validations
  validates :english_name, presence: true, uniqueness: { case_sensitive: false }
  validates :code, presence: true, uniqueness: { case_sensitive: false }
end
