class CreateReports < ActiveRecord::Migration[6.1]
  def change
    create_table :reports, id: :uuid do |t|
      t.uuid :team_diagnostic_id
      t.uuid :report_template_id
      t.string :state, default: 'pending', null: false
      t.integer :version, default: 1, null: false
      t.datetime :started_at
      t.datetime :completed_at
      t.string :description
      t.text :note
      t.uuid :token
      t.json :chart_data
      t.timestamps
    end

    add_index :reports, [ :team_diagnostic_id, :state, :version ]
  end
end
