class AddLocaleToTdqs < ActiveRecord::Migration[6.0]
  def change
    add_column :team_diagnostic_questions, :locale, :string, required: true, default: 'en'
  end
end
