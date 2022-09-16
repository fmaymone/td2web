# frozen_string_literal: true

# Invitations CRUD
class InvitationsController < ApplicationController
  before_action :authenticate_user!, except: %i[claim process_claim]
  before_action :set_invitation, only: %i[show edit update destroy]
  after_action :verify_authorized

  def index
    authorize Invitation
    @invitations = invitation_scope.order(created_at: :desc).page(@page)
    @current_page = 'All'.t
  end

  def new
    authorize Invitation
    @service = EntitlementServices::InvitationCreator.new(grantor: current_user, params: {})
    @invitation = @service.invitation
  end

  def create
    authorize Invitation
    # logger.info "Allowed ==> " + allowed_params.inspect
    @service = EntitlementServices::InvitationCreator.new(grantor: current_user, params:)
    @service.call
    if @service.success?
      redirect_to invitations_path, notice: 'Invitation sent'.t
    else
      render :new
    end
  end

  def show
    authorize @invitation
    @current_page = @invitation.email
  end

  # Disabled by Policy
  def edit
    authorize @invitation
    @current_page = @invitation.email
  end

  # Disabled by Policy
  def update
    authorize @invitation
  end

  def destroy
    authorize @invitation
    @service = EntitlementServices::InvitationDeactivator.new(@invitation)
    @service.call
    redirect_to invitations_path, notice: @service.notice
  end

  def claim
    authorize Invitation
    @token = params[:token]
    @service = EntitlementServices::InvitationClaim.new(token: @token, tenant: @current_tenant)
    assign_invitation_locale(@service.invitation)
  end

  def process_claim
    authorize Invitation
    @token = params[:token]
    @service = EntitlementServices::InvitationClaim.new(token: @token, tenant: @current_tenant)
    @invitation = @service.invitation
    assign_invitation_locale(@invitation)
    if @service.valid?
      @service.call
      redirect_to @service.redirect_url + "?invitation_id=#{@invitation.id}", notice: 'Invitation claimed'.t
    else
      flash.now[:notice] = 'Invitation not found'.t
      render :claim
    end
  end

  private

  def invitation_scope
    policy_scope(@current_tenant.invitations)
  end

  def set_invitation
    @invitation = policy_scope(Invitation).find(params[:id])
  end

  def assign_invitation_locale(invitation)
    I18n.locale = invitation&.locale || 'en'
  end
end
