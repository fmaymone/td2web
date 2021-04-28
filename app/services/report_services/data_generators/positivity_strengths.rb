# frozen_string_literal: true

module ReportServices
  module DataGenerators
    # Positivity Strengths chart data generator
    class PositivityStrengths < Base
      TITLE = 'Positivity Strengths Rating'
      ID = 'PositivityStrengths'
      VERSION = 1

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

      def responses
        @responses ||= all_avg_factor_responses_by_category('Positivity')
      end

      def factors
        @factors ||= responses.map { |r| r[:factor] }.uniq
      end

      def chart_labels
        labels = { _index: chart_data.keys }
        chart_data.keys.each_with_object(labels) do |obj, memo|
          memo[obj] = localized_string_hash(obj)
        end
        labels
      end

      def chart_data
        @chart_data ||=
          factors
          .map { |f| [f, avg_response_by_factor(f)] }
          .sort_by { |f| f[1] }
          .reverse[0..6].to_h
      end
    end
  end
end
