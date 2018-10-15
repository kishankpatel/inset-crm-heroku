class CreateEmailNotes < ActiveRecord::Migration
  def change
    create_table :email_notes do |t|
      t.integer :organization_id
      t.integer :mail_letter_id
      t.integer :user_id
      t.text :notes

      t.timestamps
    end
  end
end
