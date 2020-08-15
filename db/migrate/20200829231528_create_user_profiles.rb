class CreateUserProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :user_profiles, id: :uuid do |t|
      t.uuid :user_id
      t.string :prefix, required: true, default: ''
      t.string :first_name, required: true, default: ''
      t.string :middle_name, required: true, default: ''
      t.string :last_name, required: true
      t.string :suffix, required: true, default: ''
      t.string :pronoun, required: true, default: 'they'
      t.string :country, required: true
      t.string :company
      t.string :department
      t.string :title
      t.integer :ux_version, required: true, default: 0
      t.jsonb :consent
      t.text :staff_notes
      t.timestamps
      t.index :user_id
      t.index :ux_version
    end
  end
end
