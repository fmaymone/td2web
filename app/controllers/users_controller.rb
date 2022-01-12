# frozen_string_literal: true

# User Management Controller
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update destroy]
  after_action :verify_authorized

  def index
    authorize User
    search = UserServices::Search.new(params, policy_scope(User), current_user)
    @users = search.call
    @page_title = 'Manage User Accounts'.t
    @current_page = 'List'.t
  end

  def new
    authorize User
    @user = User.new(tenant: current_tenant, user_profile: UserProfile.new)
    @show_validation_messages = false
    @current_page = @page_title = 'New User Account'.t
  end

  def create
    authorize User
    @user = User.new(user_params)
    @user.tenant = current_tenant
    @invalid = false
    respond_to do |format|
      if @user.save
        format.html { redirect_to user_path(@user), notice: 'User was created'.t }
      else
        format.html { render :new, notice: 'There were problems'.t }
      end
    end
  end

  def show
    authorize @user
    @current_page = @user.name
  end

  def edit
    authorize @user
    @page_title = 'Edit User Account'.t
    @current_page = @user.name
  end

  def update
    authorize @user
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_path(@user), notice: 'User account updated'.t }
      else
        format.html { render :edit, notice: 'There were problems'.t }
      end
    end
  end

  # Lock User Account
  def destroy
    authorize @user
    if params[:unlock].present? && @user.locked?
      @user.unlock_access!
      notice = 'User was unlocked'.t
    else
      @user.lock_access!
      notice = 'User was locked'.t
    end
    respond_to do |format|
      format.html { redirect_to users_path, notice: }
    end
  end

  private

  def user_params
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    # Protect against privilege escalation
    if params[:user][:role_id].present?
      new_role = Role.where(id: params[:user][:role_id]).first
      params[:user].delete(:role_id) unless new_role && current_user.role >= new_role
    end
    allowed_params = policy(@user || User).allowed_params
    params.require(:user).permit(allowed_params)
  end

  def set_user
    @user = policy_scope(User).find(params[:id])
  end
end
