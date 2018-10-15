class CreateUserLicenseRequests < ActiveRecord::Migration
  def change
    create_table :user_license_requests do |t|
      t.integer :customer_id
      t.string :name
      t.string :email
      t.integer :requested_user_limit
      t.integer :amount
      t.boolean :is_license_generated, :default => false
      t.text :new_license_key

      t.timestamps
    end
  end
end
