# frozen_string_literal: true

# Translation and i18n Management
class TranslationsController < ApplicationController
  before_action :set_translation, only: %i[show edit update destroy]

  def index
    @search = TranslationServices::Search.new(params)
    @translations = @search.matching_plus_missing.group_by(&:key)
    @well_supported = ApplicationTranslation.well_supported_languages
    @minimally_supported = ApplicationTranslation.supported_languages - @well_supported
    @context = @search.options[:tlocale] || nil
    respond_to do |format|
      format.html
      format.csv do
        send_data @search.matching_plus_missing_csv, filename: 'td_translations.csv'
      end
    end
  end

  def new
    @context = params[:context]
    @service = TranslationServices::Creator.new(params)
    @translation = @service.object
    @translation.tempid = params[:id]
  end

  def create
    @context = params[:context]
    @service = TranslationServices::Creator.new(params)
    @result = @service.call
    @translation = @service.object
    @blank_translation = new_blank_translation(@translation)
    @blank_translation.locale = nil if @context.nil?
    respond_to do |format|
      if @result
        @first_of_its_name = ApplicationTranslation.where(key: @translation.key).count == 1
        I18n.backend.reload!
        format.html { redirect_to @translation, notice: 'A new Translation was added'.t }
        format.json { render json: @translation, status: :created, location: @translation }
      else
        @first_of_its_name = !ApplicationTranslation.where(key: @translation.key).exists?
        format.html { render :new }
        format.json { render json: @translation.errors, status: :unprocessable_entity }
      end
      format.js
    end
  end

  def show; end

  def edit
    @context = params[:context]
    @service = TranslationServices::Updater.new(params[:id])
    @translation = @service.object
  end

  def update
    @context = params[:context]
    @service = TranslationServices::Updater.new(params[:id], params)
    @result = @service.call
    @translation = @service.object
    respond_to do |format|
      if @result
        I18n.backend.reload!
        format.html { redirect_to @translation, notice: 'The Translation was updated'.t }
        format.json { render json: @translations, status: :updated, location: @translation }
      else
        format.html { render :edit }
        format.json { render json: @translation.errors, status: :unprocessable_entity }
      end
      format.js
    end
  end

  def destroy
    @context = params[:context]
    @blank_translation = new_blank_translation(@translation)
    @blank_translation.locale = @context if @context.present?
    @first_of_its_name = ApplicationTranslation.where(key: @translation.key).count == 1
    @translation.destroy
    I18n.backend.reload!
    respond_to do |format|
      format.html { redirect_to application_translations_path }
      format.js
    end
  end

  private

  def new_blank_translation(_translation)
    blank_translation = @translation.dup
    blank_translation.tempid = Digest::UUID.uuid_v4
    blank_translation.locale = nil
    blank_translation.value = nil
    blank_translation
  end

  def set_translation
    @translation = ApplicationTranslation.find(params[:id])
  end
end
