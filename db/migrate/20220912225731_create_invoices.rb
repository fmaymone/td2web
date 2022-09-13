class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :remoteid
      t.decimal :subtotal, null: false, default: 0.0
      t.decimal :tax, null: false, default: 0.0
      t.decimal :total, null: false, default: 0.0
      t.datetime :accepted_at
      t.datetime :paid_at
      t.string :state, null: false, default: 'pending'

      t.timestamps
    end

    add_index :invoices, [ :order_id, :state ], name: 'idx_invoices_order_and_state'
  end
end
