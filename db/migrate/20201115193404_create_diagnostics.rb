class CreateDiagnostics < ActiveRecord::Migration[6.0]
  def change
    create_table :diagnostics, id: :uuid do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.text :description, null: false
      t.boolean :active, null: false, default: false

      t.timestamps
    end
    add_index :diagnostics, :slug, unique: true
  end
end
