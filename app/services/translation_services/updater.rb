# frozen_string_literal: true

module TranslationServices
  # Translation Creator
  class Updater
    ### Class Extensions

    ### Constants
    MODEL = ApplicationTranslation
    PERMITTED_PARAMS = %w[locale key value].freeze

    ### Attributes
    attr_reader :object

    def initialize(id, params = {})
      @object = if id.is_a? String
                  MODEL.find(id)
                else
                  id
                end

      @update_params = if params.is_a?(ActionController::Parameters)
                         params.require('application_translation').permit(PERMITTED_PARAMS)
                       else
                         params
                       end
    end

    def call
      @object.update(@update_params)
    end

    def locale_options
      GlobalizeLanguage.order(iso_639_1: :asc).map do |l|
        [l.english_name, l.iso_639_1]
      end
    end

    def locale_grouped_options
      present_languages = Translation.connection.execute <<~SQL
        SELECT DISTINCT ON (translations.locale) locale,
          globalize_languages.english_name
        FROM translations
        INNER JOIN globalize_languages ON
          globalize_languages.iso_639_1 = translations.locale
        ORDER BY translations.locale
      SQL

      present_languages = present_languages.to_a.map do |l|
        [l['english_name'], l['locale']]
      end

      [['Active', present_languages], ['Unused', locale_options - present_languages]]
    end
  end
end
