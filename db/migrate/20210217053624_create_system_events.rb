class CreateSystemEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :system_events, id: :uuid do |t|
      t.references :event_source, polymorphic: true, null: false, type: :uuid
      t.references :incidental, polymorphic: true, type: :uuid
      t.string :description
      t.text :debug
      t.integer :severity, default: 1
      t.timestamps
    end
  end
end
