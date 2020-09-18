# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranslationServices::CsvImporter do
  include_context 'translations'
  before(:each) do
    translations
  end
  describe 'With valid CSV data' do
    let(:valid_csv_data) do
      [
        [language1.locale, 'key1', 'value1'],
        [language1.locale, 'key2', 'value2'],
        [language2.locale, 'key3', 'value3']
      ].map { |r| r.join(',') }.join("\n")
    end
    let(:valid_csv_update_data) do
      [
        [language1.locale, 'key1', 'value4'],
        [language1.locale, 'key2', 'value5'],
        [language2.locale, 'key3', 'value6']
      ].map { |r| r.join(',') }.join("\n")
    end

    it 'Creates Translation records from valid CSV data' do
      ApplicationTranslation.destroy_all
      translation_count = ApplicationTranslation.count
      report = []
      importer = TranslationServices::CsvImporter.new(valid_csv_data)
      results = importer.call do |info|
        report << info[:index]
      end
      new_translation_count = ApplicationTranslation.count
      expect(results.size).to eq(3)
      expect(new_translation_count - translation_count).to eq(3)
      expect(report).to eq([1, 2, 3])
    end

    it 'updated Translation records' do
      TranslationServices::CsvImporter.new(valid_csv_data).call
      record = ApplicationTranslation.where(locale: language1.locale, key: 'key1').first
      old_value = record.value
      TranslationServices::CsvImporter.new(valid_csv_update_data).call
      record.reload
      expect(record.value).to_not eq(old_value)
    end
  end

  describe 'with invalid csv data' do
    let(:invalid_csv_data) do
      [
        [language1.locale, 'key1', 'value1'],
        [language1.locale, '', 'value2'],
        [language2.locale, 'key3', 'value3']
      ].map { |r| r.join(',') }.join("\n")
    end

    it 'creates the valid records and gracefully handles invalid records' do
      ApplicationTranslation.destroy_all
      translation_count = ApplicationTranslation.count
      report = []
      importer = TranslationServices::CsvImporter.new(invalid_csv_data)
      results = importer.call do |info|
        report << info
      end
      new_translation_count = ApplicationTranslation.count
      expect(results.size).to eq(2)
      expect(report.size).to eq(3)
      expect(new_translation_count - translation_count).to eq(2)
    end
  end
end
