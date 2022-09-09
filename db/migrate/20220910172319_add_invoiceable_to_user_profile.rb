class AddInvoiceableToUserProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :user_profiles, :invoiceable, :boolean, default: true, null: false
  end
end
