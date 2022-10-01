# frozen_string_literal: true

# Dashboard/root Controller
class HomeController < ApplicationController
  before_action :authenticate_user!, except: %i[after_registration]
  skip_before_action :authorize_consent!, only: %i[request_consent grant_consent after_registration]
  after_action :verify_authorized

  def index
    authorize :home, :index?
    @page_title = 'TeamDiagnostic Home'.t
    render roled_dashboard_partial_name
  end

  def request_consent
    authorize :home, :request_consent?
    @page_title = 'User Agreements and Consent'.t
    @pending = UserProfile::REQUIRED_CONSENTS
  end

  def grant_consent
    authorize :home, :grant_consent?
    current_user.update_consents(params)
    flash[:notice] = 'Your preferences were updated'.t
    redirect_to root_path
  end

  def after_registration
    authorize :home, :after_registration?
    @page_title = 'Thank you for registering'.t
  end

  def system_events
    authorize :home, :system_events?
    @page_title = 'System Events'
    # Errors from the past two days (minutes)
    @days = 30
    @system_events = SystemEvent.notifiable.recent(60*24*@days).order(created_at: :desc)
  end

  private

  def roled_dashboard_partial_name
    "index_#{@current_user.role&.slug || 'default'}"
  end
end
