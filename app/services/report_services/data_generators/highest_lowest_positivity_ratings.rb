# frozen_string_literal: true

module ReportServices
  module DataGenerators
    # Highest and Lowest Positivity Ratings
    class HighestLowestPositivityRatings < Base
      TITLE = 'Highest Lowest Positivity Ratings'
      ID = 'HighestLowestPositivityRatings'
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
          data: {
            highest: chart_data[:highest][:data],
            lowest: chart_data[:lowest][:data]
          }
        }
      end

      private

      def highest
        @highest ||= top_responses_by_category('Positivity', 'top', 5)
      end

      def lowest
        @lowest ||= top_responses_by_category('Positivity', 'bottom', 5)
      end

      def process_responses(responses)
        keys = []
        data = []
        responses.each do |obj|
          keys << obj[:body]
          data << [obj[:body], obj[:response]]
        end
        { keys: keys, data: data }
      end

      def extract_labels(labels, responses)
        responses[:keys].each_with_object(labels) do |obj, memo|
          memo[obj] = localized_string_hash(obj)
        end
        labels
      end

      def chart_labels
        @chart_labels ||= begin
          labels = { _index: chart_data[:highest][:keys] + chart_data[:lowest][:keys] }
          labels = extract_labels(labels, chart_data[:highest])
          labels = extract_labels(labels, chart_data[:lowest])
          %w[Highest Lowest Rating].each do |label|
            labels[:_index] << label
            labels[label] = localized_string_hash(label)
          end
          labels
        end
      end

      def chart_data
        @chart_data ||= {
          highest: process_responses(highest),
          lowest: process_responses(lowest)
        }
      end
    end
  end
end
