# frozen_string_literal: true

module TranslationServices
  # Translation Creator
  class Creator
    ### Class Extensions

    ### Constants
    MODEL = ApplicationTranslation
    PERMITTED_PARAMS = %w[locale key value tempid].freeze

    ### Attributes
    attr_reader :object

    def initialize(params = {})
      permitted = if params.is_a?(ActionController::Parameters)
                    params.require('application_translation').permit(PERMITTED_PARAMS) if params[:application_translation].present?
                  else
                    params
                  end

      @object = MODEL.new(permitted)
    end

    def call
      @object.save
    end

    def locale_options
      GlobalizeLanguage.order(iso_639_1: :asc).map do |l|
        next if (l.iso_639_1 || '').empty?

        [l.english_name, l.iso_639_1]
      end.compact
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
