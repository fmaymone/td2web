# frozen_string_literal: true

module ReportServices
  module DataGenerators
    # Least Agreement Chart data generator
    class LeastAgreement < Base
      TITLE = 'Least Agreement'
      ID = 'LeastAgreement'
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

      def chart_labels
        chart[:labels]
      end

      def chart_data
        chart[:data]
      end

      def chart
        @chart ||= begin
          deviations = answer_deviations('highest')[0..4]
          labels = { _index: [] }
          deviations.each do |deviation|
            question = deviation[:question]
            labels[:_index] << question
            labels[question] = localized_string_hash(question)
          end

          data = []
          deviations.each do |deviation|
            responses = []
            members.each_with_index do |member, idx|
              responses << [idx, member_answers_by_question_id(member, deviation[:question_id]).first.response.to_f]
            end
            data << { label: deviation[:question], values: responses }
          end

          { labels: labels, data: data }
        end
      end
    end
  end
end
