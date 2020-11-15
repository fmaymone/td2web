# frozen_string_literal: true

# Manage Diagnostic Questions
class DiagnosticQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diagnostic
  before_action :set_diagnostic_question, only: %i[show edit update destroy]
  after_action :verify_authorized

  # GET /diagnostic_questions
  # GET /diagnostic_questions.json
  def index
    authorize DiagnosticQuestion
    @diagnostic_questions = diagnostic_question_scope.where(question_type: 'Rating').order(matrix: :asc)
    @open_ended_questions = diagnostic_question_scope.where(question_type: 'Open-Ended').order(matrix: :asc)
    @current_page = 'List'.t
  end

  # GET /diagnostic_questions/1
  # GET /diagnostic_questions/1.json
  def show
    authorize @diagnostic_question
  end

  # GET /diagnostic_questions/new
  def new
    authorize DiagnosticQuestion
    @diagnostic_question = DiagnosticQuestion.new(diagnostic_id: @diagnostic.id)
    @diagnostic_question.question_type = params[:question_type] if params[:question_type]
  end

  # GET /diagnostic_questions/1/edit
  def edit
    authorize @diagnostic_question
  end

  # POST /diagnostic_questions
  # POST /diagnostic_questions.json
  def create
    @diagnostic_question = DiagnosticQuestion.new(diagnostic_question_params)
    @diagnostic_question.diagnostic_id = @diagnostic.id
    authorize @diagnostic_question

    respond_to do |format|
      if @diagnostic_question.save
        format.html { redirect_to "#{diagnostic_diagnostic_questions_path(diagnostic_id: @diagnostic.id)}##{@diagnostic_question.id}", notice: 'Record was successfully created'.t }
        format.json { render :show, status: :created, location: @diagnostic_question }
      else
        format.html { render :new }
        format.json { render json: @diagnostic_question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /diagnostic_questions/1
  # PATCH/PUT /diagnostic_questions/1.json
  def update
    authorize @diagnostic_question
    respond_to do |format|
      if @diagnostic_question.update(diagnostic_question_params)
        format.html { redirect_to "#{diagnostic_diagnostic_questions_path(diagnostic_id: @diagnostic.id, id: @diagnostic_question.id)}##{@diagnostic_question.id}", notice: 'Record was successfully updated'.t }
        format.json { render :show, status: :ok, location: @diagnostic_question }
      else
        format.html { render :edit }
        format.json { render json: @diagnostic_question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diagnostic_questions/1
  # DELETE /diagnostic_questions/1.json
  def destroy
    authorize @diagnostic_question
    @diagnostic_question.destroy
    respond_to do |format|
      format.html { redirect_to diagnostic_diagnostic_questions_path(diagnostic_id: @diagnostic.id), notice: 'Record was successfully destroyed'.t }
      format.json { head :no_content }
    end
  end

  private

  def diagnostic_scope(skope = Diagnostic)
    policy_scope(skope).active
  end

  def set_diagnostic
    @diagnostic = diagnostic_scope.find(params[:diagnostic_id])
  end

  def diagnostic_question_scope(_skope = DiagnosticQuestion)
    set_diagnostic
    policy_scope(@diagnostic.diagnostic_questions)
  end

  def set_diagnostic_question
    @diagnostic_question = diagnostic_question_scope.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def diagnostic_question_params
    allowed_params = policy(@diagnostic_question || DiagnosticQuestion).allowed_params
    params.require(:diagnostic_question).permit(allowed_params)
  end
end
