# frozen_string_literal: true

# See: https://raw.githubusercontent.com/heartcombo/devise/master/app/controllers/devise/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    invitation
    assign_invitation_locale
    build_resource
    resource.role = Role.facilitator
    yield resource if block_given?
    respond_with resource
  end

  # POST /resource
  def create
    invitation
    authorizer
    assign_invitation_locale

    allowed_params = User::ALLOWED_PARAMS + [{ user_profile_attributes: UserProfile::ALLOWED_PARAMS }]
    custom_sign_up_params = params.require(:user).permit(*allowed_params)

    build_resource(custom_sign_up_params)
    resource.role = authorizer.invitation_role
    resource.tenant = current_tenant
    resource.save

    if resource.persisted?
      EntitlementServices::InvitationClaim.new(tenant: @current_tenant, token: @invitation.token, user: resource).call
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # GET /resource/edit
  def edit
    # super
    raise 'Unsupported'
  end

  # PUT /resource
  def update
    # super
    raise 'Unsupported'
  end

  # DELETE /resource
  def destroy
    # super
    raise 'Unsupported'
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # def sign_up_params
  # allowed_params = [ :username, :email, :password, :password_confirmation, :locale, :timezone, {
  # user_profile_attributes: [:prefix, :first_name, :middle_name, :last_name, :pronoun, :title, :department, :company, :country] }
  # ]
  # params.require(:user).permit(*allowed_params)
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end
  def after_sign_up_path_for(_resource)
    root_path
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
  def after_inactive_sign_up_path_for(_resource)
    after_registration_path
  end

  # Require a valid and unclaimed invitation for the current tenant
  def invitation
    @invitation ||= begin
      required_entitlement = Entitlement.where(slug: Entitlement::REGISTER_AS_FACILITATOR).first
      raise ActiveRecord::RecordNotFound unless required_entitlement.present?

      @current_tenant.invitations.unclaimed.find(params[:invitation_id])
    end
  end

  def authorizer
    invitation
    params[:token] = @invitation.token
    authorizer = EntitlementServices::Authorizer.new(user: nil, params:, tenant: @current_tenant, reference: 'Users::Registrations#')
    raise ActiveRecord::RecordNotFound unless authorizer.call

    authorizer
  end

  def assign_invitation_locale
    invitation
    I18n.locale = @invitation&.locale || 'en'
  end
end
