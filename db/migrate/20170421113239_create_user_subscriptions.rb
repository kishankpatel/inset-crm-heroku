class CreateUserSubscriptions < ActiveRecord::Migration
  def change
    create_table :user_subscriptions do |t|
      t.integer :subscription_id
      t.integer :user_limit
      t.integer :storage_limit
      t.float :price
      t.text :btsubscription_id
      t.text :btprofile_id
      t.text :cc_token
      t.string :payment_status
      t.boolean :is_cancel, :default => false
      t.string :is_updown
      t.datetime :subscription_start_date
      t.datetime :next_billing_date
      t.datetime :cancel_date
      t.boolean :is_active, :default => true
      t.references :organization
      t.references :user

      t.timestamps
    end
    add_index :user_subscriptions, :organization_id
    add_index :user_subscriptions, :user_id
  end
end
