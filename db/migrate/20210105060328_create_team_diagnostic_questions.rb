class CreateTeamDiagnosticQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :team_diagnostic_questions, id: :uuid do |t|
      t.string :slug, null: false, default: 'OEQ'
      t.uuid :team_diagnostic_id
      t.string :body, null: false
      t.string :body_positive
      t.integer :category, null: false, default: 0
      t.integer :question_type, null: false, default: 1
      t.integer :factor, null: false, default: 0
      t.integer :matrix, null: false, default: 0
      t.boolean :negative, default: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :team_diagnostic_questions, :team_diagnostic_id
    add_index :team_diagnostic_questions, :slug
    add_index :team_diagnostic_questions, [:active, :category, :question_type, :factor, :matrix], name: 'tdq_general_idx'
  end
end
