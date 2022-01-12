# frozen_string_literal: true

# Participant management controller
class ParticipantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team_diagnostic
  before_action :set_participant, only: %i[show edit update destroy disqualify restore activate]
  after_action :verify_authorized

  # GET /participants
  # GET /participants.json
  def index
    authorize Participant
    @participants = record_scope.order('last_name ASC, first_name ASC')
    @current_page = 'List'.t
  end

  # GET /participants/1
  # GET /participants/1.json
  # def show
  # authorize @participant
  # @current_page = 'Participant'.t
  # end

  # GET /participants/new
  def new
    @service = ParticipantServices::Creator.new(user: current_user, team_diagnostic: @team_diagnostic, params:)
    @participant = @service.participant
    authorize @participant
  end

  # GET /participants/1/edit
  def edit
    @service = ParticipantServices::Updater.new(user: current_user, id: @participant.id, params:)
    @participant = @service.participant
    authorize @participant
  end

  # POST /participants
  # POST /participants.json
  def create
    @service = ParticipantServices::Creator.new(user: current_user, team_diagnostic: @team_diagnostic, params:)
    authorize @service.participant

    respond_to do |format|
      created = @service.call
      @participant = @service.participant
      if created
        format.html { redirect_to new_team_diagnostic_participant_path(team_diagnostic_id: @participant.team_diagnostic.id), notice: 'Participant was added'.t }
        format.json { render :show, status: :created, location: @participant }
      else
        format.html { render :new }
        format.json { render json: @participant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /participants/1
  # PATCH/PUT /participants/1.json
  def update
    @service = ParticipantServices::Updater.new(user: current_user, id: @participant.id, params:)
    authorize @service.participant

    respond_to do |format|
      updated = @service.call
      @participant = @service.participant
      if updated
        format.html { redirect_to wizard_team_diagnostic_path(id: @participant.team_diagnostic.id, step: TeamDiagnostics::Wizard::PARTICIPANTS_STEP), notice: 'Participant was updated'.t }
        format.json { render :show, status: :ok, location: @participant }
      else
        format.html { render :edit }
        format.json { render json: @participant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /participants/1
  # DELETE /participants/1.json
  def destroy
    @service = ParticipantServices::Updater.new(user: current_user, id: @participant.id, params: {})
    authorize @service.participant
    @service.destroy!
    respond_to do |format|
      format.html { redirect_to wizard_team_diagnostic_path(id: @participant.team_diagnostic.id, step: TeamDiagnostics::Wizard::PARTICIPANTS_STEP), notice: 'Participant was removed'.t }
      format.json { head :no_content }
    end
  end

  # POST /participants/1/disqualify
  def disqualify
    @service = ParticipantServices::Updater.new(user: current_user, id: @participant.id, params: {})
    authorize @service.participant
    @service.disqualify!
    respond_to do |format|
      format.html { redirect_to wizard_team_diagnostic_path(id: @service.participant.team_diagnostic.id, step: TeamDiagnostics::Wizard::PARTICIPANTS_STEP), notice: 'Participant was disqualified'.t }
      format.json { head :no_content }
    end
  end

  # POST /participants/1/disqualify
  def restore
    @service = ParticipantServices::Updater.new(user: current_user, id: @participant.id, params: {})
    authorize @service.participant
    @service.restore!
    respond_to do |format|
      format.html { redirect_to wizard_team_diagnostic_path(id: @service.participant.team_diagnostic.id, step: TeamDiagnostics::Wizard::PARTICIPANTS_STEP), notice: 'Participant was restored'.t }
      format.json { head :no_content }
    end
  end

  # POST /participants/1/activate
  def activate
    @service = ParticipantServices::Updater.new(user: current_user, id: @participant.id, params: {})
    authorize @service.participant
    activated = @service.activate!
    notice = activated ? 'Participant was activated'.t : 'Participant could not be activated'.t
    respond_to do |format|
      format.html { redirect_to wizard_team_diagnostic_path(id: @service.participant.team_diagnostic.id, step: TeamDiagnostics::Wizard::PARTICIPANTS_STEP), notice: }
      format.json { head :no_content }
    end
  end

  def define_import
    set_team_diagnostic
    authorize @team_diagnostic
    @service = ParticipantServices::Importer.new(user: @current_user, team_diagnostic: @team_diagnostic, data: nil, options: {})
    @current_page = 'Import'.t
    @error = false
    @current_page = 'Import Participants'.t
  end

  def create_import
    set_team_diagnostic
    authorize @team_diagnostic
    @service = ParticipantServices::Importer.new(user: @current_user, team_diagnostic: @team_diagnostic, data: params[:participants], options: {})
    @service.call
    if @service.valid?
      redirect_to wizard_team_diagnostic_path(id: @team_diagnostic.id, step: TeamDiagnostics::Wizard::PARTICIPANTS_STEP), notice: 'Participants were imported successfully'.t
    else
      @errors = true
      render :define_import
    end
  end

  def resend_invitation
    set_team_diagnostic
    set_participant
    authorize @participant
    set_diagnostic_survey
    @diagnostic_survey.send_invitation_message
    redirect_to wizard_team_diagnostic_path(id: @team_diagnostic.id, step: TeamDiagnostics::Wizard::PARTICIPANTS_STEP), notice: 'Invitation resent'.t
  end

  private

  def record_scope
    @team_diagnostic ? policy_scope(@team_diagnostic.participants) : policy_scope(Participant)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_participant
    @participant = record_scope.find(params[:id])
  end

  def set_diagnostic_survey
    @diagnostic_survey = @participant.diagnostic_surveys
                                     .active
                                     .where(team_diagnostic_id: @team_diagnostic.id)
                                     .last
  end

  # Only allow a list of trusted parameters through.
  # def participant_params
  # allowed_params = policy(@participant || Participant).allowed_params
  # params.require(:participant).permit(*allowed_params)
  # end

  def set_team_diagnostic
    if params[:team_diagnostic_id]
      policy = TeamDiagnosticPolicy::Scope.new(current_user, TeamDiagnostic)
      @team_diagnostic = policy.resolve.where(id: params[:team_diagnostic_id]).first
    else
      @participant ? @participant.team_diagnostic : (raise ActiveRecord::RecordNotFound)
    end
  end
end
