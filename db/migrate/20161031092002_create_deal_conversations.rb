class CreateDealConversations < ActiveRecord::Migration
  def change
    create_table :deal_conversations do |t|
      t.integer :user_id,         null: false
      t.integer :deal_id,         null: false
      t.integer :organization_id, null: false
      t.text    :message
      t.string  :subject
      t.timestamps
    end
  end
end
