# frozen_string_literal: true

# Devise overrides for Users Confirmations Controller
class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

  def show
    super do |resource|
      # Special handling of already confirmed users visiting
      # the confirmation link
      if resource.confirmed_at.present?
        if !resource.encrypted_password?
          # Confirmed but password not set. Set password.
          redirect_to new_user_password_path(resource)
        else
          # Confirmed and password set means go to login
          redirect_to root_url
        end
        return
      end
    end
  end

  def user_set_password_path(resource)
    token = resource.send(:set_reset_password_token)
    edit_password_url(resource, reset_password_token: token)
  end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
