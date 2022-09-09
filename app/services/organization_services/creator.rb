# frozen_string_literal: true

module OrganizationServices
  # Helper class for creating Organizations
  # Restricted by Grant
  class Creator
    REFERENCE = 'Organizations#'

    attr_reader :params, :user, :grantor, :organization, :errors

    def initialize(user:, grantor: nil, params: {})
      @params = sanitize_params(params)
      @user = user
      @grantor = grantor || @user
      @organization = initialize_organization
      @errors = nil
    end

    def call
      service = EntitlementServices::GrantUsage.new(user: @grantor, reference: REFERENCE)
      unless service.call { create_organization }
        @errors ||= []
        @errors += service.errors
      end
      valid? ? @organization : false
    end

    def valid?
      @errors = Validator.new(self, action: :create).call
      @errors.empty?
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
      organization = Organization.new(@params)
      organization.tenant_id = @user.tenant_id
      organization
    end

    def create_organization
      if valid?
        Organization.transaction do
          @organization.save!
          assign_membership!
          # assign_coupons!
        end
        true
      else
        false
      end
    rescue StandardError
      false
    end

    def assign_membership!
      association = OrganizationUser.new(
        organization_id: @organization.id,
        user_id: @user.id,
        role: :admin
      )
      @errors += association.errors.full_messages unless association.valid?
      association.save!
    end

    def assign_coupons!
      return true if coupons.any?

      add_nonprofit_coupon
      true
    end

    def add_nonprofit_coupon
      return true unless @organization.nonprofit?

      Coupon.create(
        owner: @organization,
        description: Coupon::NONPROFIT_DISCOUNT_DESCRIPTION,
        stackable: false,
        active: true,
        reusable: true,
        start_date: Time.current,
        discount: Coupon::NONPROFIT_DISCOUNT
      )
    end

    def sanitize_params(params = {})
      if params.is_a?(ActionController::Parameters)
        allowed_params = OrganizationPolicy.new(@grantor, Organization).allowed_params
        data = params.require('organization').permit(*allowed_params).to_unsafe_h if params[:organization].present?
      else
        data = params
      end
      data
    end
  end
end
