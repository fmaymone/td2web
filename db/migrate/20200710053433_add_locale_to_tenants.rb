class AddLocaleToTenants < ActiveRecord::Migration[6.0]
  def change
    add_column :tenants, :locale, :string, default: 'en'
  end
end
