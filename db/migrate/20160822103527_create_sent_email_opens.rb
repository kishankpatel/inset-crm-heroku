class CreateSentEmailOpens < ActiveRecord::Migration
  def change
    create_table :sent_email_opens do |t|
      t.integer :mail_letter_id
      t.string :name
      t.string :email
      t.string :ip_address
      t.string :opened

      t.timestamps
    end
  end
end
