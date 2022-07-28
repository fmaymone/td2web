class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products, id: :uuid do |t|
      t.integer :product_type, null: false, default: 0
      t.string :slug, null: false
      t.string :name, null: false
      t.text :description
      t.decimal :price, null: false, default: 0.0
      t.jsonb :volume_pricing, null: false, default: {}
      t.jsonb :entitlement_detail, null: false, default: {}
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :products, :name, unique: true
    add_index :products, :active
  end
end
