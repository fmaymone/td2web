class CreateOrganizations < ActiveRecord::Migration[6.0]
  def change
    create_table :organizations, id: :uuid do |t|
      t.uuid :tenant_id, null: false
      t.string :name, null: false
      t.text :description
      t.string :url, null: false
      t.integer :industry, null: false
      t.integer :revenue, null: false
      t.string :locale, null: false, default: 'en'
      t.timestamps
    end

    add_index :organizations, [:tenant_id, :name], unique: true
  end
end
