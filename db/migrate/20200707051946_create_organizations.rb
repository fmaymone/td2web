class CreateOrganizations < ActiveRecord::Migration[6.0]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :name
      t.string :slug
      t.string :domain
      t.text :description
      t.boolean :active, default: false
      t.timestamps
    end
    add_index :organizations, [:domain, :active]
  end
end
