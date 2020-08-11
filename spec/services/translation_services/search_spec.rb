# frozen_string_literal: true

RSpec.describe TranslationServices::Search do
  include_context 'translations'

  let(:translations) do
    [
      create(:translation, locale: 'en', key: 'foozzz1', value: 'foozzz 1'),
      create(:translation, locale: 'en', value: 'foozzz 2'),
      create(:translation, locale: 'ar', value: 'barzzz aaa'),
      create(:translation, locale: 'ar', value: 'quux bbb')
    ]
  end

  before(:each) do
    translations
  end

  describe 'Translation search without options' do
    let(:search) { TranslationServices::Search.new }
    it 'should initialize without error' do
      search.call
    end
    it 'should return all translations' do
      expect(search.call.count).to eq(translations.size)
    end
  end

  describe 'Translation search with options' do
    it 'should filter translations by locale' do
      locale = translations.first.locale
      matches = translations.select { |t| t.locale == locale }
      search = TranslationServices::Search.new(tlocale: locale)
      results = search.call
      expect(results.count).to eq(matches.size)
    end
    it 'should filter translations by key' do
      key = 'foozzz1'
      search = TranslationServices::Search.new(key: key)
      results = search.call
      expect(results.count).to eq(1)
    end
    it 'should filter translations by value' do
      value = 'foo'
      search = TranslationServices::Search.new(value: value)
      results = search.call
      expect(results.count).to eq(2)
    end
    it 'should filter translations with a general search' do
      search = 'zzz'
      search = TranslationServices::Search.new(q: search)
      results = search.call
      expect(results.count).to eq(3)
    end
    it 'should sort results by order with template "col-direction"' do
      search = TranslationServices::Search.new(order: 'value-desc')
      results = search.call
      expect(results.first.value).to eq('quux bbb')
    end
    it 'handles invalid order params' do
      search = TranslationServices::Search.new(order: 'invalid-invalid')
      results = search.call
      expect(results.count).to eq(translations.count)
    end
    it 'handles pagination' do
      page_size = 2
      search = TranslationServices::Search.new(page: 1, page_size: page_size, paginate: 'true')
      results = search.call
      expect(results.count).to eq(page_size)
      page_size = 4
      search = TranslationServices::Search.new(page: 1, page_size: page_size, paginate: 'true')
      results = search.call
      expect(results.count).to eq(page_size)
      search = TranslationServices::Search.new(page: 1, page_size: page_size, paginate: 'true')
      results = search.call
      expect(results.count).to eq(page_size)
    end
    it 'can return only missing translations' do
      search = TranslationServices::Search.new(tlocale: language1.locale, missing: true)
      search.matching_plus_missing
    end
    it 'can return missing translations as csv' do
      search = TranslationServices::Search.new(tlocale: language1.locale, missing: true)
      results = search.matching_plus_missing_csv
      expect(results).to be_a(String)
    end
  end
end
