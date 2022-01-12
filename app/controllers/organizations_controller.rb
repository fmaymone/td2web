# frozen_string_literal: true

# Organization Management Controller
class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  # GET /organizations
  # GET /organizations.json
  def index
    authorize Organization
    @organizations = record_scope
    @current_page = 'List'.t
  end

  # GET /organizations/1
  # GET /organizations/1.json
  def show
    set_organization
    authorize @organization
    @current_page = @organization.name
  end

  # GET /organizations/new
  def new
    authorize Organization
    @service = OrganizationServices::Creator.new(user: @current_user, params:)
    @organization = @service.organization
    @current_page = 'New'
  end

  # GET /organizations/1/edit
  def edit
    @service = OrganizationServices::Updater.new(user: @current_user, params:)
    @organization = @service.organization
    raise ActiveRecord::RecordNotFound unless @organization

    authorize @organization
    @current_page = @organization.name
  end

  # POST /organizations
  # POST /organizations.json
  def create
    authorize Organization
    actual_user = params[:user_id] ? User.find(params[:user_id]) : nil
    @service = OrganizationServices::Creator.new(grantor: @current_user, user: actual_user || @current_user, params:)
    @organization = @service.organization

    respond_to do |format|
      if @service.call
        format.html { redirect_to @service.organization }
        format.json { render :show, status: :created, location: @service.organization }
      else
        format.html { render :new }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update
    @service = OrganizationServices::Updater.new(user: @current_user, params:)
    @organization = @service.organization
    raise ActiveRecord::RecordNotFound unless @organization

    authorize @organization
    respond_to do |format|
      if @service.call
        format.html { redirect_to @service.organization, notice: 'Organization was updated.'.t }
        format.json { render :show, status: :ok, location: @service.organization }
      else
        format.html { render :edit }
        format.json { render json: @service.organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    set_organization
    authorize @organization

    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_url, notice: 'Organization was deleted'.t }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_organization
    @organization = record_scope.find(params[:id])
  end

  def record_scope
    policy_scope(Organization)
  end
end
