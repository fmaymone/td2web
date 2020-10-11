class CreateGrants < ActiveRecord::Migration[6.0]
  def change
    create_table :grants, id: :uuid do |t|
      t.boolean :active, default: true
      t.uuid :user_id, null: false
      t.string :reference, null: false
      t.uuid :entitlement_id, null: false
      t.uuid :grantor_id
      t.string :grantor_type
      t.integer :quota
      t.text :description
      t.text :staff_notes
      t.datetime :granted_at

      t.timestamps
    end
    add_index :grants, [:user_id, :reference]
  end
end
