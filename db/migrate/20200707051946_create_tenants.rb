class CreateTenants < ActiveRecord::Migration[6.0]
  def change
    create_table :tenants, id: :uuid do |t|
      t.string :name
      t.string :slug
      t.string :domain
      t.text :description
      t.boolean :active, default: false
      t.timestamps
    end
    add_index :tenants, [:domain, :active]
  end
end
