# frozen_string_literal: true

RSpec.shared_context 'translations', shared_context: :metadate do
  let(:default_tenant) { create(:tenant) }
  let(:language1) {  create(:globalize_language) }
  let(:language2) {  create(:globalize_language) }
  let(:language3) {  create(:globalize_language) }
  let(:translations) do
    [
      create(:translation, locale: language1.locale, key: 'foozzz1', value: 'foozzz 1'),
      create(:translation, locale: language1.locale, key: 'foozzz2', value: 'foozzz 2'),
      create(:translation, locale: language2.locale, key: 'barzzz', value: 'barzzz aaa'),
      create(:translation, locale: language2.locale, key: 'quxx', value: 'quux bbb'),
      create(:translation, locale: language3.locale, key: 'foozzz1', value: 'foozzz 12')
    ]
  end
end
