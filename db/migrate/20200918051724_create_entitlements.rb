class CreateEntitlements < ActiveRecord::Migration[6.0]
  def change
    create_table :entitlements, id: :uuid do |t|
      t.boolean :account, default: true, null: false
      t.boolean :active, default: true, null: false
      t.uuid :role_id, null: false
      t.string :reference, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :quota
      t.timestamps
    end
    add_index :entitlements, [:slug, :role_id, :reference, :active]
    add_index :entitlements, [:slug], unique: true
  end
end
