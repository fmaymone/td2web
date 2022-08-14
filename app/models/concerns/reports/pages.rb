# frozen_string_literal: true

module Reports
  # Report Pages helper methods
  module Pages
    extend ActiveSupport::Concern

    included do
      def all_pages(locale = 'en')
        report_template.pages.locale(locale).format('html').order(index: :asc)
      end

      def available_pages(locale = 'en')
        report_template.pages.content_pages.locale(locale).format('html').order(index: :asc)
      end

      def selected_pages(locale = 'en')
        page_numbers = options.fetch('page_order', []).map(&:to_i).uniq
        default_available_pages = available_pages(locale).to_a
        pages = page_numbers.map { |n| default_available_pages[n - 1] }.compact
        pages.empty? ? default_available_pages : pages
      end

      def page_order
        available_page_indexes = available_pages.pluck(:index).sort
        return available_page_indexes unless options['page_order'].present?

        options['page_order'].map(&:to_i) || available_page_indexes
      end
    end
  end
end
