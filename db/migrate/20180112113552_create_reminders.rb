class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.references :task
      t.references :user
      t.boolean :is_reminder, :default => false
      t.boolean :is_reminder_sent, :default => false
      t.datetime :reminder_datetime

      t.timestamps
    end
    add_index :reminders, :task_id
    add_index :reminders, :user_id
  end
end
