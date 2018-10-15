class CreateEmailAccounts < ActiveRecord::Migration
  def change
    create_table :email_accounts do |t|
      t.string :provider
      t.string :email
      t.string :access_token
      t.string :refresh_token
      t.boolean :expires, default: true
      t.integer :expires_in, default: 3600
      t.integer :expires_at
      t.integer :user_id
      t.integer :organization_id

      t.timestamps
    end
  end
end
