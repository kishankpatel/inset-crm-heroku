class CreateBounceEmails < ActiveRecord::Migration
  def change
    create_table :bounce_emails do |t|
      t.integer :organization_id
      t.string :sender_email
      t.string :recipient_email

      t.timestamps
    end
  end
end
