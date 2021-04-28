# frozen_string_literal: true

module ReportServices
  # Report chart data generator
  module DataGenerators
    # TeamMatrixPosition DataGenerator class
    class TeamMatrixPosition < Base
      TITLE = 'Team Matrix Position'
      ID = 'TeamMatrixPosition'
      VERSION = 1
      PRODUCTIVITY = 'Productivity'
      POSITIVITY = 'Positivity'
      HIGH_PRODUCTIVITY = 'High Productivity'
      LOW_PRODUCTIVITY = 'Low Productivity'
      HIGH_POSITIVITY = 'High Positivity'
      LOW_POSITIVITY = 'Low Positivity'

      def id
        ID
      end

      def call
        high_productivity = top_responses_by_category(PRODUCTIVITY, 'top', 1).first[:response]
        low_productivity = top_responses_by_category(PRODUCTIVITY, 'bottom', 1).first[:response]
        high_positivity = top_responses_by_category(POSITIVITY, 'top', 1).first[:response]
        low_positivity = top_responses_by_category(POSITIVITY, 'bottom', 1).first[:response]

        {
          title: localized_string_hash(TITLE),
          version: VERSION,
          domain: [1.0, 9.0],
          labels: {
            _index: [HIGH_PRODUCTIVITY, LOW_POSITIVITY, LOW_PRODUCTIVITY, HIGH_POSITIVITY],
            HIGH_PRODUCTIVITY => localized_string_hash(HIGH_PRODUCTIVITY),
            LOW_PRODUCTIVITY => localized_string_hash(LOW_PRODUCTIVITY),
            HIGH_POSITIVITY => localized_string_hash(HIGH_POSITIVITY),
            LOW_POSITIVITY => localized_string_hash(LOW_POSITIVITY)
          },
          data: {
            HIGH_PRODUCTIVITY => high_productivity,
            LOW_PRODUCTIVITY => low_productivity,
            HIGH_POSITIVITY => high_positivity,
            LOW_POSITIVITY => low_positivity
          }
        }
      end
    end
  end
end
