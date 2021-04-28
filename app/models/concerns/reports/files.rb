# frozen_string_literal: true

module Reports
  module Files
    extend ActiveSupport::Concern

    included do
      has_many_attached :report_files
    end
  end
end
