class CreateParticipants < ActiveRecord::Migration[6.0]
  def change
    create_table :participants, id: :uuid do |t|
      t.uuid :team_diagnostic_id, null: false
      t.string :state, null: false, default: 'approved'
      t.string :email, null: false
      t.string :phone
      t.string :title
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :locale, null: false
      t.string :timezone, null: false
      t.text :notes

      t.timestamps
    end

    add_index :participants, [:team_diagnostic_id, :state]
    add_index :participants, [:team_diagnostic_id, :email], unique: true
  end
end
