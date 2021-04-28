# frozen_string_literal: true

# == Schema Information
#
# Table name: report_template_pages
#
#  id                 :uuid             not null, primary key
#  report_template_id :uuid
#  slug               :string
#  index              :integer
#  locale             :string
#  format             :string
#  name               :string
#  markup             :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class ReportTemplatePage < ApplicationRecord
  # CONVENTIONS
  #
  # LAYOUT:
  # For the overall report layout, ensure there is a record with
  # the slug `layout` for a given report template, format, and locale

  ### Scopes
  scope :locale, ->(locale) { where(locale: locale) }
  scope :format, ->(format) { where(format: format) }
  scope :layout_page, -> { where(slug: 'layout') }
  scope :content_pages, -> { where.not(slug: 'layout') }

  validates :index, uniqueness: { scope: %i[locale format] }

  ### Associations
  belongs_to :report_template
end
