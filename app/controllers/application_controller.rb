# frozen_string_literal: true

# Rails application base controller
class ApplicationController < ActionController::Base
  before_action :set_current_organization

  private

  def set_current_organization
    @current_organization = organization_from_hostname
  end

  # Lookup and return Organization by request domain, or Organization.default_or
  def organization_from_hostname
    Organization.active.where(domain: request.host).first ||
      Organization.default_org
  end
end
