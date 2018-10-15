class AddUserToUserHourlyBillable < ActiveRecord::Migration
  def change
    add_column :user_hourly_billables, :user_id, :integer, references: :user
    add_column :user_hourly_billables, :is_active, :boolean, :default => true
  end
end
