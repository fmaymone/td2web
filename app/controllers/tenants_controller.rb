# frozen_string_literal: true

# Tenants CRUD
class TenantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tenant, only: %i[show edit update destroy]
  after_action :verify_authorized

  # GET /tenants
  # GET /tenants.json
  def index
    authorize Tenant
    @tenants = Tenant.all
    @page_title = 'TeamDiagnostic Tenants'.t
    @current_page = 'All'.t
  end

  # GET /tenants/1
  # GET /tenants/1.json
  def show
    authorize @tenant
    @current_page = @tenant.name
  end

  # GET /tenants/new
  def new
    authorize Tenant
    @tenant = Tenant.new
  end

  # GET /tenants/1/edit
  def edit
    authorize @tenant
    @current_page = @tenant.name
  end

  # POST /tenants
  # POST /tenants.json
  def create
    authorize Tenant
    @tenant = Tenant.new(tenant_params)

    respond_to do |format|
      if @tenant.save
        format.html { redirect_to @tenant, notice: 'record was created'.t(record: 'Tenant') }
        format.json { render :show, status: :created, location: @tenant }
      else
        format.html { render :new }
        format.json { render json: @tenant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tenants/1
  # PATCH/PUT /tenants/1.json
  def update
    authorize Tenant
    @current_page = @tenant.name
    respond_to do |format|
      if @tenant.update(tenant_params)
        format.html { redirect_to @tenant, notice: 'record was updated'.t(record: 'Tenant') }
        format.json { render :show, status: :ok, location: @tenant }
      else
        format.html { render :edit }
        format.json { render json: @tenant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tenants/1
  # DELETE /tenants/1.json
  def destroy
    authorize @tenant
    @tenant.destroy
    respond_to do |format|
      format.html { redirect_to tenants_url, notice: 'record was destroyed'.t(record: 'Tenant') }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tenant
    @tenant = Tenant.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def tenant_params
    allowed_params = policy(@tenant || Tenant).allowed_params
    params.require(:tenant).permit(allowed_params)
  end
end
