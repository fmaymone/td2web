class CreateDiagnosticResponses < ActiveRecord::Migration[6.1]
  def change
    create_table :diagnostic_responses, id: :uuid do |t|
      t.uuid :diagnostic_survey_id, null: false
      t.uuid :team_diagnostic_question_id, null: false
      t.string :locale, null: false
      t.text :response, null: false
      t.timestamps
    end
    add_index :diagnostic_responses, [:diagnostic_survey_id, :team_diagnostic_question_id, :locale], name: :diagnostic_responses_unique_idx, unique: true
  end
end
