class CreateReportTemplatePages < ActiveRecord::Migration[6.1]
  def change
    create_table :report_template_pages, id: :uuid do |t|
      t.uuid :report_template_id
      t.string :slug
      t.integer :index
      t.string :locale
      t.string :format
      t.string :name
      t.text :markup

      t.timestamps
    end
    add_index :report_template_pages, [:report_template_id, :format, :locale, :index], name: :order_idx
    add_index :report_template_pages, [:report_template_id, :slug, :format, :locale], name: :slug_idx, unique: true
  end
end
