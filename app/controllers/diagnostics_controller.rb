# frozen_string_literal: true

# Diagnostic Management Controller
class DiagnosticsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diagnostic, only: %i[show edit update destroy]
  after_action :verify_authorized

  # GET /diagnostics
  # GET /diagnostics.json
  def index
    authorize Diagnostic
    @diagnostics = diagnostic_scope.order(name: :asc)
    @current_page = 'All'.t
  end

  # GET /diagnostics/1
  # GET /diagnostics/1.json
  def show
    authorize @diagnostic
    @current_page = @diagnostic.name
  end

  # GET /diagnostics/new
  def new
    authorize Diagnostic
    @diagnostic = Diagnostic.new
  end

  # GET /diagnostics/1/edit
  def edit
    authorize @diagnostic
    @current_page = @diagnostic.name
  end

  # POST /diagnostics
  # POST /diagnostics.json
  def create
    authorize Diagnostic
    @diagnostic = Diagnostic.new(diagnostic_params)

    respond_to do |format|
      if @diagnostic.save
        format.html { redirect_to @diagnostic, notice: 'record was created'.t(record: 'Diagnostic') }
        format.json { render :show, status: :created, location: @diagnostic }
      else
        format.html { render :new }
        format.json { render json: @diagnostic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /diagnostics/1
  # PATCH/PUT /diagnostics/1.json
  def update
    authorize @diagnostic
    respond_to do |format|
      if @diagnostic.update(diagnostic_params)
        format.html { redirect_to @diagnostic, notice: 'record was updated'.t(record: 'Diagnostic') }
        format.json { render :show, status: :ok, location: @diagnostic }
      else
        format.html { render :edit }
        format.json { render json: @diagnostic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diagnostics/1
  # DELETE /diagnostics/1.json
  #
  # NOT SUPPORTED to ensure system integrity
  def destroy
    raise ActiveRecord::RecordNotFound
  end

  private

  def diagnostic_params
    allowed_params = policy(@diagnostic || Diagnostic).allowed_params
    params.require(:diagnostic).permit(allowed_params)
  end

  def diagnostic_scope(skope = Diagnostic)
    policy_scope(skope)
  end

  def set_diagnostic
    @diagnostic = policy_scope(Diagnostic).find(params[:id])
  end
end
