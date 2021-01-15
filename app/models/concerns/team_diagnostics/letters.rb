# frozen_string_literal: true

module TeamDiagnostics
  # Letter logic for TeamDiagnostics
  module Letters
    extend ActiveSupport::Concern

    included do
      has_many :team_diagnostic_letters, dependent: :destroy
      accepts_nested_attributes_for :team_diagnostic_letters

      def missing_letters
        all_locales = ([locale] + participants.pluck(:locale)).uniq.sort
        letter_types = TeamDiagnosticLetter::LETTER_TYPES
        all_combinations = []
        letter_types.each { |t| all_locales.each { |l| all_combinations << [t, l] } }
        existing_combinations = team_diagnostic_letters.pluck(:letter_type, :locale)
        missing_combinations = all_combinations - existing_combinations
        missing_combinations.map { |mc| TeamDiagnosticLetter.default_letter(type: mc[0], locale: mc[1], team_diagnostic: self) }
      end
    end
  end
end
