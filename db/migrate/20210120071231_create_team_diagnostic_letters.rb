class CreateTeamDiagnosticLetters < ActiveRecord::Migration[6.0]
  def change
    create_table :team_diagnostic_letters, id: :uuid do |t|
      t.uuid :team_diagnostic_id, required: true
      t.integer :letter_type, required: true
      t.string :locale, required: true, default: 'en'
      t.string :subject, required: true
      t.text :body, required: true
      t.timestamps
    end

    add_index :team_diagnostic_letters, [:team_diagnostic_id, :letter_type, :locale], unique: true, name: :tdl_general_idx
  end
end
