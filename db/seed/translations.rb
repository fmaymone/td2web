# frozen_string_literal: true

module Seeds
  # Translation seeder
  class Translations
    attr_reader :errors

    def initialize(message: nil, filename: nil)
      default_filename = File.join(__dir__, 'translations.csv')
      @message = message || 'Load Translations...'
      @filename = filename || default_filename
      @errors = []
    end

    def call
      print @message if @message
      collection = TranslationServices::CsvImporter.new(File.read(@filename)).call do |info|
        @errors << info[:error] if info[:error]
      end
      !collection.empty?
    end
  end
end
