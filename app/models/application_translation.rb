# frozen_string_literal: true

# Decorator for the Translation class
class ApplicationTranslation < I18n::Backend::ActiveRecord::Translation
  ## CONSTANTS
  PERMITTED_PARAMS = %w[key value locale].freeze

  ### Extensions and Concerns
  audited

  ### Validations
  validates :locale, presence: true
  validates :key, presence: true
  validates :value, presence: true

  ### Associations
  belongs_to :language, class_name: 'GlobalizeLanguage', foreign_key: :locale, primary_key: :iso_639_1

  attr_accessor :tempid

  ### Class Methods
  class << self
    def supported_languages
      result = ApplicationTranslation.connection.execute <<~SQL
        SELECT globalize_languages.english_name,
          translations.locale,
          count(translations.id)
        FROM translations
        INNER JOIN globalize_languages
        ON globalize_languages.iso_639_1 = translations.locale
        GROUP BY translations.locale, globalize_languages.english_name
        ORDER BY globalize_languages.english_name
      SQL
      result.to_a
    end

    def well_supported_languages
      supported_languages.select do |lang|
        lang['count'] > 50
      end
    end
  end
end