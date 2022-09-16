# frozen_string_literal: true

# Rails application base controller
class ApplicationController < ActionController::Base
  add_flash_types :info, :error, :warning, :notice

  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  rescue_from UserProfile::ConsentUnauthorizedError, with: :user_has_not_consented
  # rescue_from EntitlementServices::Authorizer::AuthorizationError, with: :user_is_not_entitled

  protect_from_forgery with: :exception

  # Order is important!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :current_tenant
  before_action :current_locale
  before_action :authorize_consent!, unless: :devise_controller?
  before_action :set_page
  around_action :user_timezone, if: :current_user

  private

  def user_timezone(&)
    @user_timezone ||= Time.use_zone(current_user.timezone, &)
  end

  def current_tenant
    @current_tenant ||= set_current_tenant
  end

  def current_locale
    @current_locale ||= set_locale
  end

  # globalization locale set
  def set_locale
    I18n.locale = if params.include? :locale
                    params[:locale]
                  elsif current_user
                    current_user.locale
                  elsif current_tenant
                    current_tenant.locale
                  else
                    'en'
                  end
  end

  def set_current_tenant
    @current_tenant = tenant_from_hostname
  end

  def set_page
    @page = params[:page] || 1
  end

  # Lookup and return Tenant by request domain, or Organization.default_tenant
  def tenant_from_hostname
    Tenant.active.where(domain: request.host).first || Tenant.default_tenant
  end

  def authorize_consent!
    raise UserProfile::ConsentUnauthorizedError if user_signed_in? && current_user.required_consent_pending?

    true
  end

  def authorize_entitlements!(slug = nil)
    authorizer = EntitlementServices::Authorizer.new(params:, user: current_user)
    raise EntitlementServices::Authorizer::AuthorizationError, 'Entitlement authorization failed' unless authorizer.call(slug)

    true
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: %i[username name email password password_confirmation locale timezone])
    devise_parameter_sanitizer.permit(:sign_in,
                                      keys: %i[login password password_confirmation])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[username name email password_confirmation current_password locale timezone])
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'.t
    redirect_to(request.referrer || root_path)
  end

  def user_has_not_consented
    flash[:alert] = 'Please review site terms and conditions'.t
    redirect_to(request_consent_path)
  end

  def user_is_not_entitled
    flash[:alert] = 'You are not entitled to perform this action'.t
    redirect_to(request.referrer || root_path)
  end
end
