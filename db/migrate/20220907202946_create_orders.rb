class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.string :orderid, null: false
      t.references :user
      t.uuid :orderable_id, null: false
      t.string :orderable_type, null: false
      t.decimal :subtotal, null: false, default: 0.0
      t.decimal :tax, null: false, default: 0.0
      t.decimal :total, null: false, default: 0.0
      t.datetime :submitted_at
      t.integer :payment_method, null: false, default: 0
      t.string :state, null: false, default: 'pending'

      t.timestamps
    end

    add_index :orders, [:state, :user_id, :orderid ], unique: true, name: 'idx_orders_general'
    add_index :orders, [:orderable_id, :orderable_type], name: 'idx_orders_orderable'
  end
end
