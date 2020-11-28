# frozen_string_literal: true

module TranslationServices
  # Family Tribes Question Extractor
  class FamilyTribesExtractor
    I18N_MODEL = ApplicationTranslation
    I18N_LOCALE = 'ft'
    CSV_DIAGNOSTIC_ID = 6

    def initialize
      @reference_diagnostic = Diagnostic.where(slug: Diagnostic::TDA_SLUG).first
      @diagnostic = Diagnostic.where(slug: Diagnostic::FAMILY_TRIBES_SLUG).first
      @collection = []
      @not_found = []
      raise 'Family Tribies Diagnostic not found!' unless @diagnostic.present?
    end

    # Return CSV seed data for FamilyTribes DiagnosticQuestions
    def call
      extract_questions
      puts "*** SKIPPED: #{@not_found.size}"
      puts @not_found.map { |nf| "  - #{nf}" }.join("\n")
      puts "*** CREATED: #{@collection.size}"
      puts @collection.map { |q| "  - #{q.body_positive || q.body}" }.join("\n")
      csv_from_questions
    end

    private

    def extract_questions
      @collection = []
      @not_found = []
      @reference_diagnostic.diagnostic_questions.each do |ref|
        begin
          xtln_body = ApplicationTranslation.where(locale: I18N_LOCALE, key: ref.body).first.value
          xtln_body_positive = ref.negative? ? ApplicationTranslation.where(locale: I18N_LOCALE, key: ref.body_positive).first.value : nil
        rescue StandardError
          puts "SKIPPED: '#{ref.body}'. FT translation not found"
          @not_found << ref.body
          next
        end
        q = DiagnosticQuestion.new(
          diagnostic: @diagnostic,
          body: xtln_body,
          body_positive: xtln_body_positive,
          category: ref.category,
          question_type: ref.question_type,
          factor: ref.factor,
          matrix: ref.matrix,
          negative: ref.negative,
          active: true
        )
        q.send(:create_slug)
        @collection << q
      end
      @collection
    end

    def csv_from_questions
      CSV.generate do |csv|
        @collection.sort_by(&:matrix).each do |q|
          csv << [
            q.slug,
            CSV_DIAGNOSTIC_ID,
            q.body,
            q.body_positive,
            q.category,
            q.factor,
            q.question_type,
            q.matrix,
            q.negative,
            q.active
          ]
        end
      end
    end

    def ft_translations
      I18N_MODEL.where(locale: I18N_LOCALE)
    end
  end
end
