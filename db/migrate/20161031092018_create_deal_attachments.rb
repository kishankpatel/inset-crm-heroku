class CreateDealAttachments < ActiveRecord::Migration
  def change
    create_table :deal_attachments do |t|
      t.attachment  :attachment
      t.integer     :deal_conversation_id,  null: false
      t.integer     :organization_id,       null: false
      t.timestamps
    end
  end
end
