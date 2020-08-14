# frozen_string_literal: true

# Rails application base controller
class ApplicationController < ActionController::Base
  before_action :current_tenant
  before_action :current_locale

  def current_tenant
    @current_tenant ||= set_current_tenant
  end

  def current_locale
    @current_locale ||= set_locale
  end

  private

  # globalization locale set
  def set_locale
    I18n.locale = if params.include? :locale
                    params[:locale]
                  elsif current_tenant
                    current_tenant.locale
                  else
                    'en'
                  end
  end

  def set_current_tenant
    @current_tenant = tenant_from_hostname
  end

  # Lookup and return Tenant by request domain, or Organization.default_tenant
  def tenant_from_hostname
    Tenant.active.where(domain: request.host).first || Tenant.default_tenant
  end
end
