# frozen_string_literal: true

# Grants Management Controller Scoped Under Users
class GrantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_grant, only: %i[show edit update destroy]
  after_action :verify_authorized

  # Disabled in Policy
  def index
    authorize Grant
    # @grants = @user.grants
  end

  def new
    authorize Grant
    @grant = Grant.new(user: @user, grantor: current_user)
  end

  def create
    authorize Grant
    @grant = Grant.new(grant_params)
    @grant.reference ||= @grant.entitlement&.reference
    @grant.granted_at ||= DateTime.now
    @grant.grantor = current_user
    respond_to do |format|
      if @grant.save
        format.html { redirect_to user_path(@user), notice: 'Grant added'.t }
      else
        format.html { render :new }
      end
    end
  end

  # Disabled in Policy
  def show
    authorize @grant
  end

  def edit
    authorize @grant
  end

  def update
    authorize @grant
    respond_to do |format|
      if @grant.update(grant_params)
        format.html { redirect_to @user, notice: 'Grant was updated'.t }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    authorize @grant
    if params[:deactivate]
      @grant.active = false
      @grant.save
      msg = 'Grant was deactivated'.t
    else
      @grant.destroy
      msg = 'Grant was removed'.t
    end
    redirect_to @user, notice: msg
  end

  private

  def set_grant
    @grant = grant_scope.find(params[:id])
  end

  def set_user
    @user = policy_scope(User).find(params[:user_id])
  end

  def grant_params
    allowed_params = policy(@grant || Grant).allowed_params
    params.require(:grant).permit(allowed_params)
  end

  def grant_scope
    @user ||= set_user
    policy_scope(@user.grants)
  end
end
