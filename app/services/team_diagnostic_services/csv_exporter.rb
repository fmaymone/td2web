# frozen_string_literal: true

module TeamDiagnosticServices
  # TeamDiagnostic Results CSV exporter
  class CsvExporter
    def initialize(team_diagnostic)
      @team_diagnostic = team_diagnostic
    end

    def call
      to_csv(data_for_export)
    end

    private

    def data_for_export
      locale = @team_diagnostic.locale
      header = ['id'] + @team_diagnostic.team_diagnostic_questions
                                        .where(active: true)
                                        .order('question_type ASC, matrix ASC')
                                        .pluck(:body)
                                        .map{|r|
                                          ApplicationTranslation.where(locale: locale , key: r ).first.value
                                        }

      [header] + @team_diagnostic.diagnostic_surveys.completed.map do |survey|
        [survey.id] + survey.diagnostic_responses
                            .includes(:team_diagnostic_question)
                            .order('team_diagnostic_questions.question_type ASC, team_diagnostic_questions.matrix ASC')
                            .pluck(:response)
      end
    end

    def to_csv(data)
      CSV.generate do |csv|
        data.each do |row|
          csv << row
        end
      end
    end
  end
end
