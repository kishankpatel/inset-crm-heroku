class CreateSelfHostingUsers < ActiveRecord::Migration
  def change
    create_table :self_hosting_users do |t|
      t.string :license_type
      t.text :license_key
      t.integer :user_limit
      t.boolean :installation_support, :default => false
      t.string :name
      t.string :email
      t.string :phone
      t.string :gmt_offset
      t.string :location
      t.string :ip
      t.text :referrer
      t.text :transaction_id
      t.string :transaction_status
      t.integer :invoice_id
      t.boolean :is_emailed
      t.text :token
      t.datetime :download_date
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
