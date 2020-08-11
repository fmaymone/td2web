# frozen_string_literal: true

# Rails application base controller
class ApplicationController < ActionController::Base
  before_action :current_organization
  before_action :current_locale

  def current_organization
    @current_organization ||= set_current_organization
  end

  def current_locale
    @current_locale ||= set_locale
  end

  private

  # globalization locale set
  def set_locale
    I18n.locale = if params.include? :locale
                    params[:locale]
                  elsif current_organization
                    current_organization.locale
                  else
                    'en'
                  end
  end

  def set_current_organization
    @current_organization = organization_from_hostname
  end

  # Lookup and return Organization by request domain, or Organization.default_or
  def organization_from_hostname
    Organization.active.where(domain: request.host).first || Organization.default_org
  end
end
