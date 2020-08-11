class AddLocaleKeyIndexToTranslations < ActiveRecord::Migration[6.0]
  def change
    add_index :translations, [:locale, :key], unique: true
  end
end
