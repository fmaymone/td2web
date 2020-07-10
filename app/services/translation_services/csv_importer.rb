# frozen_string_literal: true

module TranslationServices
  # Imports Translations from a CSV file
  class CsvImporter
    require 'csv'

    # Initialize with a String
    def initialize(csvdata)
      @data = csvdata
    end

    def call(&block)
      collection = []
      rowdata = 0
      index = 0
      CSV.parse(@data).each_with_index do |row, i|
        error = nil
        index = i
        rowdata = row
        attrs = { locale: row[0], key: row[1], value: row[2] }
        service = creator_or_updater(attrs)
        begin
          collection << service.object if service.call
        rescue StandardError => e
          error = ["!!! Error adding #{rowdata} @#{index + 1}", e.message]
        end
        status = if error.present?
                   :error
                 elsif service.is_a?(TranslationServices::Creator)
                   :new
                 elsif service.object.changed?
                   :updated
                 else
                   :noop
                 end
        record_info = {
          object: service.object,
          index: index + 1,
          data: rowdata,
          error: error,
          status: status
        }
        yield(record_info) if block.present?
      end
      collection
    end

    private

    def creator_or_updater(attrs)
      key_data = { locale: attrs[:locale], key: attrs[:key] }
      xltn = TranslationServices::Search::REPOSITORY.where(key_data).first
      if xltn
        TranslationServices::Updater.new(xltn, attrs)
      else
        TranslationServices::Creator.new(attrs)
      end
    end
  end
end
