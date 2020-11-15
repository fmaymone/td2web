class CreateDiagnosticQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :diagnostic_questions, id: :uuid do |t|
      t.string :slug, null: false
      t.uuid :diagnostic_id
      t.string :body, null: false
      t.string :body_positive
      t.integer :category, null: false
      t.integer :question_type, null: false
      t.integer :factor, null: false
      t.integer :matrix, null: false
      t.boolean :negative, default: false
      t.boolean :active, null: false, default: false

      t.timestamps
    end
    add_index :diagnostic_questions, :diagnostic_id
    add_index :diagnostic_questions, :slug, unique: true
    add_index :diagnostic_questions, [:active, :category, :question_type, :factor, :matrix], name: 'general_idx'
  end
end
