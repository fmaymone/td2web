# frozen_string_literal: true

module UserServices
  # User Creator
  class Creator
    ### Class Extensions

    ### Constants
    MODEL = User
    ALLOWED_PARAMS = MODEL::ALLOWED_PARAMS
    PROFILE_ALLOWED_PARAMS = %w[].freeze

    ### Attributes
    attr_reader :object

    def initialize(creator, params = {})
      @creator = creator

      permitted = if params.is_a?(ActionController::Parameters)
                    params.require('application_translation').permit(PERMITTED_PARAMS) if params[:application_translation].present?
                  else
                    params
                  end

      @object = MODEL.new(permitted)
    end

    def call; end

    private

    def permitted_params(params)
      if params.is_a?(ActionController::Parameters)
        full_permitted_params = ALLOWED_PARAMS.merge({ user_profile: PROFILE_ALLOWED_PARAMS })
        params.require('user').permit(full_permitted_params) if params[:user].present?
      else
        params
      end
    end
  end
end
