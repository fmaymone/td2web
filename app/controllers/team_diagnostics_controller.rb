# frozen_string_literal: true

# TeamDiagnostic Management Controller
class TeamDiagnosticsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  # GET /team_diagnostics
  # GET /team_diagnostics.json
  def index
    authorize TeamDiagnostic
    set_organization
    skope = @organization ? record_scope.where(organization_id: @organization.id) : record_scope
    @team_diagnostics = skope.order(due_at: :desc)
    @current_page = 'List'.t
  end

  # GET /team_diagnostics/1
  # GET /team_diagnostics/1.json
  def show
    set_team_diagnostic
    authorize @team_diagnostic
    set_organization
    @current_page = @team_diagnostic.name

    redirect_to wizard_team_diagnostic_path(@team_diagnostic, step: @team_diagnostic.wizard) # if @team_diagnostic.setup? || @team_diagnostic.deployed?
  end

  # GET /team_diagnostics/new
  def new
    authorize TeamDiagnostic
    @service = TeamDiagnosticServices::Creator.new(user: @current_user, params: params)
    @team_diagnostic = @service.team_diagnostic
    set_organization
    @current_page = 'New'.t
  end

  # GET /team_diagnostics/1/edit
  def edit
    @service = TeamDiagnosticServices::Updater.new(user: @current_user, id: record_scope.find(params[:id]), params: params)
    @team_diagnostic = @service.team_diagnostic
    set_organization

    @current_page = @team_diagnostic.name
    authorize @team_diagnostic
  end

  # POST /team_diagnostics
  # POST /team_diagnostics.json
  def create
    @service = TeamDiagnosticServices::Creator.new(user: @current_user, params: params)
    authorize @service.team_diagnostic

    respond_to do |format|
      success = @service.call
      @team_diagnostic = @service.team_diagnostic
      if success
        format.html { redirect_to @team_diagnostic, notice: 'Team Diagnostic created'.t }
        format.json { render :show, status: :created, location: @team_diagnostic }
      else
        format.html { render :new }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /team_diagnostics/1
  # PATCH/PUT /team_diagnostics/1.json
  def update
    @service = TeamDiagnosticServices::Updater.new(user: @current_user, id: record_scope.find(params[:id]), params: params)
    authorize @service.team_diagnostic

    respond_to do |format|
      success = @service.call
      @team_diagnostic = @service.team_diagnostic
      if success
        format.html { redirect_to @team_diagnostic, notice: 'Team Diagnostic updated'.t }
        format.json { render :show, status: :ok, location: @team_diagnostic }
      else
        @participant_service = ParticipantServices::Creator.new(user: @current_user, team_diagnostic: @team_diagnostic, params: {})
        @participant = @participant_service.participant
        @current_page = @service.step_name.capitalize
        format.html { render :wizard }
        format.json { render json: @team_diagnostic.errors, status: :unprocessable_entity }
      end
    end
  end

  def wizard
    @service = TeamDiagnosticServices::Updater.new(user: @current_user, id: record_scope.find(params[:id]), params: params)
    @team_diagnostic = @service.team_diagnostic
    authorize @team_diagnostic
    # redirect_to @team_diagnostic unless @team_diagnostic.setup? || @team_diagnostic.deployed?

    case @service.step
    when TeamDiagnostics::Wizard::PARTICIPANTS_STEP
      @participant_service = ParticipantServices::Creator.new(user: @current_user, team_diagnostic: @team_diagnostic, params: {})
      @participant = @participant_service.participant
    when TeamDiagnostics::Wizard::QUESTIONS_STEP
      @question_service = TeamDiagnosticServices::QuestionCreator.new(user: @current_user, team_diagnostic: @team_diagnostic, params: {})
      @team_diagnostic_question = @question_service.team_diagnostic_question
    end
    set_organization
    @current_page = @service.step_name.capitalize
  end

  # DELETE /team_diagnostics/1
  # DELETE /team_diagnostics/1.json
  def destroy
    raise 'Not yet supported'
    # @team_diagnostic.destroy
    # respond_to do |format|
    # format.html { redirect_to team_diagnostics_url, notice: 'Team Diagnostic deleted'.t }
    # format.json { head :no_content }
    # end
  end

  def deploy
    set_team_diagnostic
    authorize @team_diagnostic
    if @team_diagnostic.deploy!
      redirect_to team_diagnostic_path(@team_diagnostic), notice: 'Team Diagnostic was manually deployed'.t
    else
      redirect_to team_diagnostic_path(@team_diagnostic), error: 'Team Diagnostic deployment failed'.t
    end
  end

  def cancel
    set_team_diagnostic
    authorize @team_diagnostic
    redirect_to team_diagnostic_path(@team_diagnostic), notice: 'Team Diagnostic was cancelled'.t if @team_diagnostic.cancel!
  end

  private

  def record_scope
    policy_scope(TeamDiagnostic)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_team_diagnostic
    @team_diagnostic = record_scope.find(params[:id])
  end

  def set_organization
    @organization = if (organization_id = params[:organization_id])
                      OrganizationPolicy::Scope.new(current_user, Organization).resolve
                                               .where(id: organization_id).first
                    else
                      @team_diagnostic ? @team_diagnostic.organization : nil
                    end
  end
end
