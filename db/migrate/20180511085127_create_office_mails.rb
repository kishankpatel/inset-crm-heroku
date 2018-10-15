class CreateOfficeMails < ActiveRecord::Migration
  def change
    create_table :office_mails do |t|
      t.references :organization
      t.references :user
      t.string :office_mail
      t.text :token_hash
      t.string :token

      t.timestamps
    end
    add_index :office_mails, :organization_id
    add_index :office_mails, :user_id
  end
end
