class CreateReportTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :report_templates, id: :uuid do |t|
      t.uuid :tenant_id, null: false
      t.uuid :diagnostic_id, null: false
      t.string :name, null: false
      t.string :state, null: false, default: 'draft'
      t.integer :version, null: false, default: 1
      t.timestamps
    end

    add_index :report_templates, [:tenant_id, :diagnostic_id, :state, :version], name: 'report_templates_idx'
  end
end
