class CreateOrderItems < ActiveRecord::Migration[6.1]
  def change
    create_table :order_items, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.string :description, null: false
      t.integer :quantity, null: false, default: 0
      t.decimal :unit_price, null: false, default: 0.0
      t.decimal :total, null: false, default: 0.0
      t.integer :index, null: false, default: 0

      t.timestamps
    end

    add_index :order_items, :order_id, name: 'idx_order_items_order_id'
  end
end
