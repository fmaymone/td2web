class AddPhoneToUserProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :user_profiles, :phone_number, :string
    UserProfile.update_all(phone_number: '555-555-5555')
    change_column_null :user_profiles, :phone_number, false
  end
end
