class CreateInvitations < ActiveRecord::Migration[6.0]
  def change
    create_table :invitations, id: :uuid do |t|
      t.uuid :tenant_id, required: true
      t.boolean :active, required: true, default: true
      t.string :token, required: true
      t.uuid :grantor_id
      t.string :grantor_type
      t.jsonb :entitlements, required: true
      t.string :email, required: true
      t.text :description
      t.string :redirect
      t.string :locale, required: true, default: 'en'
      t.string :i18n_key, required: true
      t.datetime :claimed_at
      t.uuid :claimed_by_id

      t.timestamps
    end

    add_index :invitations, [:tenant_id, :active, :token]
    add_index :invitations, [:claimed_by_id]
  end
end
