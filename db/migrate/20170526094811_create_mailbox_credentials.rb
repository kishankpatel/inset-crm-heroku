class CreateMailboxCredentials < ActiveRecord::Migration
  def change
    create_table :mailbox_credentials do |t|
      t.string :client_id
      t.string :client_secret

      t.timestamps
    end
  end
end
