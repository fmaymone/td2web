class AddUserProfileNotificationPreferences < ActiveRecord::Migration[6.1]
  def change
    add_column :user_profiles, :notification_preferences, :jsonb
  end
end
