class CreateRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.string :description

      t.timestamps
    end

    add_index :roles, :slug, unique: true
    add_index :roles, :name, unique: true
  end
end
