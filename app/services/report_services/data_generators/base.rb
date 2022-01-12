# frozen_string_literal: true

module ReportServices
  # Report chart data generator
  module DataGenerators
    # Base DataGenerator class
    class Base
      def initialize(team_diagnostic)
        @team_diagnostic = team_diagnostic
      end

      def localized_string_hash(text)
        @team_diagnostic.all_locales.each_with_object({}) do |locale, memo|
          memo[locale] = I18n.with_locale(locale) { text }
        end
      end

      def members
        @team_diagnostic.participants.completed
      end

      def all_responses
        @team_diagnostic.responses
      end

      def rating_questions
        @team_diagnostic.team_diagnostic_questions.rating
      end

      def open_ended_questions
        @team_diagnostic.team_diagnostic_questions.open_ended
      end

      ### Team functions from TDv1
      #

      # returns the maximum or minimum (+extrema+) response
      # among all members for all answers:
      #  extrema_response_by_cateogry("min", "Positivity")
      def extrema_response_by_category(extrema, category)
        skope = all_responses.rating.where(category:)

        case extrema
        when 'min'
          skope.minimum(:response)
        when 'max'
          skope.maximum(:response)
        end
      end

      # returns the average response among all members for
      # a given +factor+.
      # example:
      #  avg_response_by_factor("Decision Making")
      def avg_response_by_factor(factor)
        all_responses.rating
                     .includes(:team_diagnostic_question)
                     .where(team_diagnostic_questions: { factor: })
                     .average('CAST(response as INTEGER)')
                     .round(1)
      end

      # returns the average response among all members for
      # a given +question_id+.
      #  for each member, collect answers by question_id, remove
      #  nils/emptys (no responses), build an array and then
      #  take the average
      # example:
      #  avg_response_by_question_id(1)
      def avg_response_by_question_id(question_id)
        all_responses
          .rating
          .where(team_diagnostic_question_id: question_id)
          .average('CAST(response as INTEGER)')
          .round(1)
      end

      # returns an array of ALL average responses among all
      # members for a given +category+, sorted from high to
      # low.
      # example:
      #  all_avg_responses_by_category("Positivity")
      def all_avg_responses_by_category(category)
        responses = rating_questions.where(category:)
                                    .each_with_object([]) do |q, memo|
          memo << {
            body: q.body,
            body_positive: q.body_positive,
            response: avg_response_by_question_id(q.id)
          }
        end
        responses.sort { |a, b| b[:response] <=> a[:response] }
      end

      # returns an array of ALL average responses per factor
      # among all members for a given +category+, sorted
      # from high to low.
      # example:
      #  all_avg_factor_responses_by_category("Positivity")
      def all_avg_factor_responses_by_category(category)
        responses = rating_questions.where(category:)
                                    .pluck(:factor).uniq.each_with_object([]) do |factor, memo|
          memo << {
            factor:,
            response: avg_response_by_factor(factor)
          }
        end
        responses.sort { |a, b| b[:response] <=> a[:response] }
      end

      # returns the top +number+ responses among all members for a given
      # +category+, sorted from high to low.
      # The +segment+ can be "top" or "bottom" to alter sorting.
      # example:
      #  top_responses_by_category("Positivity", "top", 5)
      def top_responses_by_category(category, segment = 'top', number = 5)
        all_avg_responses = all_avg_responses_by_category(category)
        case segment
        when 'top'
          all_avg_responses[0...number]
        when 'bottom'
          all_avg_responses[-number...all_avg_responses.size]
        else
          [] # unknown segment
        end
      end

      # returns the answers with the +extrema+ standard deviations
      # example:
      # answer_deviations("highest")   # returns highest std deviations
      #   # {:std_deviation=>2.82842712474619, :min_max=>[3, 7], :question_id=>12}
      #
      def answer_deviations(extrema = 'highest')
        deviations = []
        rating_questions.each do |q|
          # get all responses by question
          responses = members.collect { |member| member_answers_by_question_id(member, q.id) }.flatten.map { |r| r.response.to_f }
          response_count = responses.size.to_f
          # calculate the mean/average
          mean = responses.sum / response_count
          # use the mean to calculate variance
          variance = responses.inject(0.0) { |v, x| v + ((x - mean)**2) }
          # std_deviation is the square root of variance / total
          std_deviation = if responses.size > 1
                            Math.sqrt(variance / response_count)
                          else
                            0.0
                          end
          deviations << { question_id: q.id, std_deviation: std_deviation.nan? ? 0.0 : std_deviation, min_max: responses.minmax, question: q.body }
        end
        sorted_deviations = deviations.sort_by { |x| x[:std_deviation] }
        extrema == 'lowest' ? sorted_deviations : sorted_deviations.reverse
      end

      ###
      ### Team methods from TDv1

      ### Member methods from TDv1
      ###

      def member_answers(member)
        survey = member&.diagnostic_surveys&.completed&.last
        return [] unless survey

        member.diagnostic_surveys
              .completed.order(completed_at: :desc).first
              .diagnostic_responses
      end

      # returns an Array of uncompleted answers (without responses)
      def uncompleted_answers
        raise 'Unsupported'
        # member_all_answers.select { |a| a.response.blank? }
      end

      def member_answers_count(member)
        member_answers(member).size
      end

      def member_answers_by_category(member, category)
        member_answers(member).where(category:)
      end

      def member_answers_by_factor(member, factor)
        member_answers(member).where(factor:)
      end

      def member_answers_by_question_id(member, question_id)
        member_answers(member).where(team_diagnostic_question_id: question_id)
      end
    end
  end
end
