# frozen_string_literal: true

module OrganizationServices
  # Helper class for updating Organizations
  class OrganizationUpdater
    REFERENCE = 'Organizations#'

    attr_reader :params, :user, :organization, :errors

    def initialize(user:, params: {}); end

    private

    def sanitize_params(params = {})
      if params.is_a?(ActionController::Parameters)
        data = params.require('organization').permit!.to_unsafe_h if params[:organization].present?
      else
        data = params
      end
      data
    end

    def validate
      @errors = []
      validate_access
      validate_record
    end

    def validate_access
      @errors << 'You do not have permission to create an Organization' unless OrganizationPolicy.new(@grantor, Organization).new?
    end

    def validate_record
      @errors += @organization.errors.full_messages unless @organization.valid?
    end
  end
end
