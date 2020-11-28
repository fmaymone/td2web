class RemoveUniqueNameFromOrganizations < ActiveRecord::Migration[6.0]
  def change
    remove_index :organizations, [:tenant_id, :name]
  end
end
