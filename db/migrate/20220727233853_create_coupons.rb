class CreateCoupons < ActiveRecord::Migration[6.1]
  def change
    create_table :coupons, id: :uuid do |t|
      t.string :code, null: false
      t.string :description, null: false
      t.boolean :stackable, null: false, default: false
      t.boolean :active, null: false, default: true
      t.date :start_date
      t.date :end_date
      t.integer :discount, null: false, default: 0
      t.uuid :product_id, null: false
      t.uuid :owner_id
      t.string :owner_type

      t.timestamps
    end

    add_index :coupons, :code, unique: true
    add_index :coupons, [:owner_id, :owner_type], name: 'coupons_owner_idx'
    add_index :coupons, [ :active, :product_id ], name: 'coupons_product_idx'
  end
end
