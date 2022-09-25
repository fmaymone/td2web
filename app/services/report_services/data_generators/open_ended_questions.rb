module ReportServices
  module DataGenerators
    # Open Ended Question Reponses
    class OpenEndedQuestions < Base
      TITLE = 'Open-Ended Questions'
      ID = 'OpenEndedQuestions'
      VERSION = 1

      def id
        ID
      end

      def call
        {
          title: localized_string_hash(TITLE),
          version: VERSION,
          domain: [],
          labels: chart_labels,
          data: {
            responses: open_ended_responses_data
          }
        }
      end

      private

      def chart_labels
        labels = { _index: open_ended_questions.map(&:id) }
        open_ended_questions.each_with_object(labels) do |obj, memo|
          memo[obj.id] = localized_string_hash(obj.body)
        end
        labels
      end

      def open_ended_responses
        @open_ended_responses ||= all_responses.open_ended.to_a.
          map{ |response|
            {
              question_id: response.team_diagnostic_question_id,
              response: response.response
            }
          }
      end

      def open_ended_responses_data
        open_ended_responses.each_with_object({}) do |obj, memo|
          question_id = obj[:question_id].to_sym
          memo[question_id] ||= []
          memo[question_id] << obj[:response]
        end
      end

    end
  end
end
