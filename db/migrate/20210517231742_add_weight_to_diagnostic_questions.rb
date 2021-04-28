class AddWeightToDiagnosticQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :diagnostic_questions, :weight, :decimal, default: 0.0, null: false
    #remove_index :diagnostic_questions, name: :general_idx
    add_index :diagnostic_questions, [:active, :category, :question_type, :factor, :matrix, :weight], name: 'general_idx'
  end
end
