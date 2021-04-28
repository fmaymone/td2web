# frozen_string_literal: true

module ReportServices
  module DataGenerators
    # Polar chart data generator
    class PolarChart < Base
      TITLE = 'Polar Chart'
      ID = 'PolarChart'
      VERSION = 1
      FACTORS = ['Constructive Interaction', 'Values Diversity', 'Optimism', 'Alignment', 'Goals & Strategies', 'Accountability', 'Proactive', 'Decision Making', 'Resources', 'Team Leadership', 'Trust', 'Respect', 'Camaraderie', 'Communication'].freeze

      def id
        ID
      end

      def call
        {
          title: localized_string_hash(TITLE),
          version: VERSION,
          domain: [1.0, 9.0],
          labels: chart_labels,
          data: chart_data
        }
      end

      private

      def chart_labels
        labels = { _index: FACTORS }
        FACTORS.each_with_object(labels) do |obj, memo|
          memo[obj] = localized_string_hash(obj)
        end
        labels
      end

      def chart_data
        FACTORS.each_with_object({}) do |obj, memo|
          memo[obj] = avg_response_by_factor(obj)
        end
      end
    end
  end
end
