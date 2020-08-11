class RequireTranslationValue < ActiveRecord::Migration[6.0]
  def change
    change_column_null :translations, :locale, false
    change_column_null :translations, :key, false
    change_column_null :translations, :value, false
  end
end
