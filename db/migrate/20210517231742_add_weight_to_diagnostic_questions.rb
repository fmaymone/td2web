class AddWeightToDiagnosticQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :diagnostic_questions, :weight, :decimal, default: 0.0, null: false
    add_index :diagnostic_questions, [:active, :category, :question_type, :factor, :matrix, :weight], name: 'diagq_general_idx'
  end
end
