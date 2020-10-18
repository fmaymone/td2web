class CreateOrganizationUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :organization_users, id: :uuid do |t|
      t.uuid :organization_id, null: false
      t.uuid :user_id, null: false
      t.integer :role, null: false
      t.timestamps
    end

    add_index :organization_users, [:organization_id, :user_id], unique: true
  end
end
