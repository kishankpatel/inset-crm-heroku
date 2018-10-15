class CreateInAppNotifications < ActiveRecord::Migration
  def change
    create_table :in_app_notifications do |t|
      t.references :organization
      t.references :user
      t.string :activity_type
      t.string :notificationable_type
      t.integer :notificationable_id
      t.string :message
      t.boolean :is_read, :default => false

      t.timestamps
    end
    add_index :in_app_notifications, :organization_id
    add_index :in_app_notifications, :user_id
  end
end
