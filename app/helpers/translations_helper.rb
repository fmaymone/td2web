# frozen_string_literal: true

# Translation and i18n Management View Helpers
module TranslationsHelper
  def supported_languages_for_select(selected)
    options_for_select(
      ApplicationTranslation.supported_languages.map { |l| [l['english_name'], l['locale']] },
      selected
    )
  end
end
