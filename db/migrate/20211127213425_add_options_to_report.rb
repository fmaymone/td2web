class AddOptionsToReport < ActiveRecord::Migration[6.1]
  def change
    add_column :reports, :options, :json, default: {}
  end
end
