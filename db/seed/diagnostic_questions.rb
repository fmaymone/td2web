# frozen_string_literal: true

# Seed Diagnostic Questions
module Seeds
  # DiagnosticQuestion seed data
  class DiagnosticQuestions
    DEFAULT_FILENAME = File.join(Rails.root, 'db', 'seed', 'diagnostic_questions.csv').freeze

    def initialize(message: nil, filename: DEFAULT_FILENAME)
      @message = message || 'Load Default DiagnosticQuestions...'
      @errors = []
      @success = false
      @filename = filename
    end

    def call
      DiagnosticQuestion.load_seed_csv_data(@filename) do |record|
        # Find the ACTUAL Diagnostic ID
        new_record = record.dup
        diagnostic_id = case record[:diagnostic_id].to_i
                        when 1
                          Diagnostic.where(slug: Diagnostic::TDA_SLUG).first.id
                        when 2
                          Diagnostic.where(slug: Diagnostic::TLV_SLUG).first.id
                        when 3
                          Diagnostic.where(slug: Diagnostic::T360_SLUG).first.id
                        when 4
                          Diagnostic.where(slug: Diagnostic::ORG_SLUG).first.id
                        when 5
                          Diagnostic.where(slug: Diagnostic::LEAD_360_SLUG).first.id
                        when 6
                          Diagnostic.where(slug: Diagnostic::FAMILY_TRIBES_SLUG).first.id
                        end
        new_record[:diagnostic_id] = diagnostic_id
        new_record
      end
    end

    private

    def log(message)
      puts message
      Rails.logger.info message
    end
  end
end
