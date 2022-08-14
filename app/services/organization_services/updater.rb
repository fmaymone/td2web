# frozen_string_literal: true

module OrganizationServices
  # Helper class for updating Organizations
  class Updater
    REFERENCE = 'Organizations#'

    attr_reader :params, :user, :organization, :errors

    def initialize(user:, params: {})
      @id = params[:id]
      @params = sanitize_params(params || {})
      @user = user
      @errors = nil
      @organization = initialize_organization
    end

    def valid?
      @errors ||= Validator.new(self, action: :update).call
      @errors.empty?
    end

    def call
      update_organization ? @organization : false
    end

    def locale_options
      GlobalizeLanguage.order(:english_name).map { |l| [l.english_name.t, l.iso_639_1] }
    end

    def industry_options
      Organization.industries.keys.map { |i| [i.t, i] }
    end

    def revenue_options
      Organization.revenues.keys.map { |i| [i.t, i] }
    end

    def user_options
      @grantor.tenant.users.map { |u| [u.name, u.id] }
    end

    private

    def initialize_organization
      organization = OrganizationPolicy::Scope.new(@user, Organization).resolve.where(id: @id).first
      @errors = ['You do not have access to this Organization'] unless organization.present?
      organization
    end

    def update_organization
      return false unless @organization.present?

      begin
        @organization.assign_attributes(@params)
      # Handle enum-related errors because they are not caught by validations
      rescue ArgumentError => e
        @errors ||= []
        @errors << e.to_s
      end
      if valid? && @organization.save
        deactivate_nonprofit_coupon_if_profit
        @organization
      else
        @errors += @organization.errors.full_messages
        false
      end
    end

    def deactivate_nonprofit_coupon_if_profit
      unless @organization.nonprofit?
        coupons = @organization.coupons.where(description: Coupon::NONPROFIT_DISCOUNT_DESCRIPTION)
        if @organization.orders.any?
          coupons.update_all(active: false)
        else
          coupons.destroy_all
        end
      end
      @organization.coupons.reload
    end

    def sanitize_params(params = {})
      if params.is_a?(ActionController::Parameters)
        data = params.require('organization').permit!.to_unsafe_h if params[:organization].present?
      else
        data = params
      end
      data.delete(:tenant_id) if data&.fetch(:tenant_id, nil).present?
      data
    end
  end
end
