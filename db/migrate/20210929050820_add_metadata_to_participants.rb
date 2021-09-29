class AddMetadataToParticipants < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :metadata, :json, default: ''
  end
end
