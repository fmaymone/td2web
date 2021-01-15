class CreateDiagnosticSurveys < ActiveRecord::Migration[6.0]
  def change
    create_table :diagnostic_surveys, id: :uuid do |t|
      t.uuid :team_diagnostic_id, null: false
      t.uuid :participant_id, null: false
      t.string :state, null: false, default: 'pending'
      t.string :locale, null: false, default: 'en'
      t.text :notes
      t.datetime :last_activity_at
      t.datetime :delivered_at
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :diagnostic_surveys, [:team_diagnostic_id, :participant_id, :state], name: 'diagnostic_surveys_idx'
  end
end
