# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/translations', type: :request do
  include_context 'translations'

  before(:each) do
    translations
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      get application_translations_url
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
    describe 'as CSV' do
      it 'renders a successful response' do
        get application_translations_url, params: { format: 'csv' }
        expect(response).to be_successful
      end
    end
    describe 'with filters' do
      describe 'filtered by missing' do
        it 'renders a successful response' do
          get application_translations_url, params: { missing: 'true', tlocale: translations.first.locale }
          expect(response).to be_successful
        end
      end
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_application_translation_url
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    let(:valid_attributes) { { locale: language1.locale, key: 'bb', value: 'bbv' } }
    let(:invalid_attributes) { { locale: language2.locale, key: 'bb', value: '' } }
    describe 'with valid attributes' do
      it 'should create a new translation' do
        count = ApplicationTranslation.count
        post application_translations_url, params: { application_translation: valid_attributes }
        expect(assigns['translation']).to be_valid
        expect(ApplicationTranslation.count).to eq(count + 1)
      end
      it 'should redirect to the translation list' do
        post application_translations_url, params: { application_translation: valid_attributes }
        expect(response).to redirect_to(application_translation_url(assigns['translation']))
      end
    end
    describe 'with invalid attributes' do
      it 'should not create a new translation' do
        count = ApplicationTranslation.count
        post application_translations_url, params: { application_translation: invalid_attributes }
        expect(assigns['translation']).to_not be_valid
        expect(ApplicationTranslation.count).to eq(count)
      end
      it 'should re-render the form' do
        post application_translations_url, params: { application_translation: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET /edit' do
    let(:translation) { translations.first }
    it 'should render the edit form' do
      get edit_application_translation_url(translation)
      expect(response).to be_successful
      expect(response).to render_template(:edit)
    end
  end

  describe 'PUT update' do
    let(:translation) { translations.first }
    let(:new_value) { 'foobar' }
    let(:valid_attributes) { translation.attributes.merge(value: new_value) }
    let(:invalid_attributes) { translation.attributes.merge(key: nil) }
    describe 'with valid attributes' do
      it 'should update the record' do
        put application_translation_url(translation), params: { application_translation: valid_attributes }
        translation.reload
        expect(translation.value).to eq(new_value)
      end
      it 'should redirect to the record' do
        put application_translation_url(translation), params: { application_translation: valid_attributes }
        translation.reload
        expect(response).to redirect_to(application_translation_url(translation))
      end
    end
    describe 'with invalid attributes' do
      it 'should not update the record' do
        old_value = translation.value
        assert(new_value != old_value)
        put application_translation_url(translation), params: { application_translation: invalid_attributes }
        translation.reload
        expect(translation.value).to eq(old_value)
      end
      it 'should re-render the form' do
        old_value = translation.value
        assert(new_value != old_value)
        put application_translation_url(translation), params: { application_translation: invalid_attributes }
        translation.reload
        expect(response).to render_template('translations/edit')
      end
    end
  end
  describe 'DELETE /destroy' do
    let(:translation) { translations.first }
    it 'should destroy the record' do
      delete application_translation_url(translation)
      expect(Translation.where(id: translation.id).count).to eq(0)
    end
  end
end
