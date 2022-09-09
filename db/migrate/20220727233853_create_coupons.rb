class CreateCoupons < ActiveRecord::Migration[6.1]
  def change
    create_table :coupons, id: :uuid do |t|
      t.string :code, null: false
      t.string :description, null: false
      t.boolean :stackable, null: false, default: false
      t.boolean :active, null: false, default: true
      t.boolean :reusable, null: false, default: false
      t.date :start_date
      t.date :end_date
      t.integer :discount, null: false, default: 0
      t.uuid :product_id
      t.uuid :owner_id
      t.string :owner_type

      t.timestamps
    end

    add_index :coupons, [:active, :code ], unique: true, name: 'idx_coupons_general'
    add_index :coupons, [:owner_id, :owner_type], name: 'idx_coupons_owner'
    add_index :coupons, [ :active, :product_id ], name: 'idx_coupons_product'
  end
end
