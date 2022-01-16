class AddWeightToDiagnosticQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :diagnostic_questions, :weight, :decimal, default: 0.0, null: false
    if index_exists? :diagnostic_questions, 'general_idx'
      remove_index :diagnostic_questions, [:active, :category, :question_type, :factor, :matrix, :weight], name: 'general_idx'
    end
    add_index :diagnostic_questions, [:active, :category, :question_type, :factor, :matrix, :weight], name: 'general_idx'
  end
end
