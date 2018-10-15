class CreateDealTransactions < ActiveRecord::Migration
  def change
    create_table :deal_transactions do |t|
      t.integer :organization_id
      t.integer :deal_id
      t.integer :deal_status_id
      t.integer :user_id

      t.timestamps
    end
  end
end
