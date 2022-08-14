class CreateOrderDiscounts < ActiveRecord::Migration[6.1]
  def change
    create_table :order_discounts, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.references :coupon, null: false, foreign_key: true, type: :uuid
      t.string :description, null: false
      t.decimal :total, null: false, default: 0.0

      t.timestamps
    end
  end
end
