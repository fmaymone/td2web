class CreateGrantUsages < ActiveRecord::Migration[6.0]
  def change
    create_table :grant_usages, id: :uuid do |t|
      t.uuid :grant_id
      t.timestamps
      t.index :grant_id
    end
  end
end
