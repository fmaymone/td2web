class CreateTeamDiagnostics < ActiveRecord::Migration[6.0]
  def change
    create_table :team_diagnostics, id: :uuid do |t|
      t.uuid :organization_id, null: false
      t.uuid :user_id, null: false
      t.uuid :team_diagnostic_id
      t.uuid :diagnostic_id, null: false
      t.string :state, null: false, default: 'setup'
      t.string :locale, null: false, default: 'en'
      t.string :timezone, null: false
      t.string :name, null: false
      t.text :description, null: false
      t.text :situation
      t.string :functional_area, null: false
      t.string :team_type, null: false
      t.boolean :show_members, null: false, default: true
      t.string :contact_phone, null: false
      t.string :contact_email, null: false
      t.string :alternate_email
      t.text :cover_letter, null: false
      t.text :reminder_letter, null: false
      t.text :cancellation_letter, null: false
      t.datetime :due_at, null: false
      t.datetime :completed_at
      t.datetime :deployed_at
      t.datetime :auto_deploy_at
      t.datetime :reminder_at
      t.datetime :reminder_sent_at

      t.timestamps
    end
    add_index :team_diagnostics, [ :user_id, :organization_id, :state ]
    add_index :team_diagnostics, :team_diagnostic_id
  end
end
