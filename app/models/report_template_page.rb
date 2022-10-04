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
  ### Constants
  LAYOUT_PAGE_SLUG = 'layout'

  ### Concerns
  include Seeds::Seedable

  # CONVENTIONS
  #
  # LAYOUT:
  # For the overall report layout, ensure there is a record with
  # the slug `layout` for a given report template, format, and locale

  ### Scopes
  scope :locale, ->(locale) { where(locale:) }
  scope :format, ->(format) { where(format:) }
  scope :layout_page, -> { where(slug: LAYOUT_PAGE_SLUG) }
  scope :content_pages, -> { where.not(slug: LAYOUT_PAGE_SLUG) }

  validates :index, uniqueness: { scope: %i[locale format report_template_id] }

  ### Associations
  belongs_to :report_template
end
