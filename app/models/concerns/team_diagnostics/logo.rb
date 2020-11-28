# frozen_string_literal: true

module TeamDiagnostics
  # Logo extensions for the TeamDiagnostic model
  module Logo
    extend ActiveSupport::Concern

    included do
      attr_accessor :_destroy_logo

      has_one_attached :logo

      after_save :destroy_logo

      def destroy_logo
        logo.purge_later if _destroy_logo == '1'
      end
    end
  end
end
