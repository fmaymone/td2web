# frozen_string_literal: true

module TranslationServices
  # Exports Translations to a CSV String
  class CsvExporter
    require 'csv'

    DEFAULT_FILENAME = 'tmp/translations.csv'

    # Initialize with a parameter Hash
    #
    # { filename: 'path/to/export.csv', search: {locale: ...} }
    #
    # See Services::Translations::Search for supported search params
    def initialize(params = {})
      export_search_params = params
      export_search_params[:paginate] = false
      @search = TranslationServices::Search.new(export_search_params)
    end

    def call
      CSV.generate do |csv|
        collection.each do |x|
          csv << [x.locale, x.key, x.value]
        end
      end
    end

    private

    def collection
      @search.call.all
    end
  end
end
