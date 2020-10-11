# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranslationServices::CsvExporter do
  include_context 'translations'

  before(:each) do
    translations
  end

  describe 'Without search params' do
    it 'should export all Translation data as a CSV string' do
      exporter = TranslationServices::CsvExporter.new
      result = exporter.call
      result_array = CSV.parse(result)
      expect(result_array.size).to eq(translations.size)
      expect(result_array[0][2]).to eq(translations.first.value)
    end
  end

  describe 'with search params' do
    it 'should export only matching Translations\' data' do
      export_locale = translations.first.locale
      exporter = TranslationServices::CsvExporter.new({ tlocale: export_locale })
      result = exporter.call
      result_array = CSV.parse(result)
      expect(result_array.size).to eq(ApplicationTranslation.where(locale: export_locale).count)
      expect(result_array.map { |r| r[0] }.uniq).to eq([export_locale])
    end
  end
end
