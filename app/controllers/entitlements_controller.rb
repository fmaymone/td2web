# frozen_string_literal: true

# Entitlement Management Controller
class EntitlementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entitlement, only: %i[show edit update destroy]
  after_action :verify_authorized

  def index
    authorize Entitlement
    @entitlements = entitlement_scope.order(reference: :asc)
    @current_page = 'All'.t
  end

  def new
    authorize Entitlement
    @entitlement = Entitlement.new
  end

  def create
    authorize Entitlement
    @entitlement = Entitlement.new(entitlement_params)
    respond_to do |format|
      if @entitlement.save
        format.html { redirect_to @entitlement, notice: 'Entitlement was successfully created'.t }
      else
        format.html { render :new }
      end
    end
  end

  def show
    authorize @entitlement
    @current_page = @entitlement.slug
  end

  def edit
    authorize @entitlement
    @current_page = @entitlement.slug
  end

  def update
    authorize @entitlement
    respond_to do |format|
      if @entitlement.update(entitlement_params)
        format.html { redirect_to @entitlement, notice: 'Entitlement was updated'.t }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    authorize @entitlement
    @entitlement.destroy
    redirect_to entitlements_path, notice: 'Entitlement was destroyed'.t
  end

  private

  def entitlement_params
    allowed_params = policy(@entitlement || Entitlement).allowed_params
    params.require(:entitlement).permit(allowed_params)
  end

  def entitlement_scope(skope = Entitlement)
    policy_scope(skope)
  end

  def set_entitlement
    @entitlement = Entitlement.find(params[:id])
  end
end
