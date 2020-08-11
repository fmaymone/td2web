class AddLocaleToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :locale, :string, default: 'en'
  end
end
