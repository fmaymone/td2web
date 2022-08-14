# frozen_string_literal: true

# TeamDiagnostic Management Controller
class TeamDiagnosticsController < ApplicationController
  before_action :authenticate_user!, except: [:report]
  after_action :verify_authorized, except: [:report]

  layout 'report', only: [:report]

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
    @service = TeamDiagnosticServices::Creator.new(user: @current_user, params:)
    @team_diagnostic = @service.team_diagnostic
    set_organization
    @current_page = 'New'.t
  end

  # GET /team_diagnostics/1/edit
  def edit
    @service = TeamDiagnosticServices::Updater.new(user: @current_user, id: record_scope.find(params[:id]), params:)
    @team_diagnostic = @service.team_diagnostic
    set_organization

    @current_page = @team_diagnostic.name
    authorize @team_diagnostic
  end

  # POST /team_diagnostics
  # POST /team_diagnostics.json
  def create
    @service = TeamDiagnosticServices::Creator.new(user: @current_user, params:)
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
    @service = TeamDiagnosticServices::Updater.new(user: @current_user, id: record_scope.find(params[:id]), params:)
    authorize @service.team_diagnostic

    respond_to do |format|
      success = @service.call
      @team_diagnostic = @service.team_diagnostic
      if success
        format.html { redirect_to @team_diagnostic, notice: @service.update_notice }
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
    @service = TeamDiagnosticServices::Updater.new(user: @current_user, id: record_scope.find(params[:id]), params:)
    @team_diagnostic = @service.team_diagnostic
    authorize @team_diagnostic
    @current_page = @service.step_name.capitalize
    set_organization

    case @service.step
    when TeamDiagnostic::PARTICIPANTS_STEP
      @participant_service = ParticipantServices::Creator.new(user: @current_user, team_diagnostic: @team_diagnostic, params: {})
      @participant = @participant_service.participant
    when TeamDiagnostic::QUESTIONS_STEP
      @question_service = TeamDiagnosticServices::QuestionCreator.new(user: @current_user, team_diagnostic: @team_diagnostic, params: {})
      @team_diagnostic_question = @question_service.team_diagnostic_question
    when TeamDiagnostic::REPORT_STEP
      @report_service = TeamDiagnosticServices::Reporter.new(@team_diagnostic)
    end
  end

  # DELETE /team_diagnostics/1
  # DELETE /team_diagnostics/1.json
  def destroy
    raise 'Not yet supported'
    # @team_diagnostic.destroy
    # respond_to do |format|
    # format.html { redirect_to team_diagnostics_url, notice: 'Team Diagnostic deleted'.t }
    # format.json { :no_content }
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

  def complete
    set_team_diagnostic
    @team_diagnostic.force_completion = true
    authorize @team_diagnostic
    redirect_to team_diagnostic_path(@team_diagnostic), notice: 'Team Diagnostic was completed'.t if @team_diagnostic.complete!
  end

  def export
    set_team_diagnostic
    authorize @team_diagnostic
    respond_to do |format|
      format.csv do
        @service = TeamDiagnosticServices::CsvExporter.new(@team_diagnostic)
        send_data @service.call, filename: "#{@team_diagnostic.locale}-export-#{@team_diagnostic.id}.csv"
      end
    end
  end

  # Authenticated by report token
  def report
    @team_diagnostic = TeamDiagnostic.find(params[:id])
    @report = @team_diagnostic.reports.find(params[:report_id])
    head :not_allowed if @report.token != params[:token]
    @locale = current_locale || @report.team_diagnostic.locale
    @report_service = TeamDiagnosticServices::Reporter.new(@team_diagnostic)
    @html_file = @report_service.current_report&.html_files(locale: @locale)&.last
    raise ActiveRecord::RecordNotFound unless @html_file

    @page_title = @report.description
  end

  def generate_report
    @service = TeamDiagnosticServices::Updater.new(user: @current_user, id: record_scope.find(params[:id]), params:)
    @team_diagnostic = @service.team_diagnostic
    authorize @team_diagnostic

    @report_service = TeamDiagnosticServices::Reporter.new(@team_diagnostic)

    options = { page_order: params[:page_order], report_variation: params[:report_variation] }
    logger.info("ZZZZ: #{options.inspect}")
    @report_service.call(options:)
    notice = 'Your report is being generated'.t
    redirect_to wizard_team_diagnostic_path(@team_diagnostic, step: @team_diagnostic.wizard), notice:
  end

  def customize_report
    @service = TeamDiagnosticServices::Updater.new(user: @current_user, id: record_scope.find(params[:id]), params:)
    @team_diagnostic = @service.team_diagnostic
    authorize @team_diagnostic
    @report_service = TeamDiagnosticServices::Reporter.new(@team_diagnostic)
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
