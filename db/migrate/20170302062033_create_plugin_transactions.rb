class CreatePluginTransactions < ActiveRecord::Migration
  def change
    create_table :plugin_transactions do |t|
      t.integer :community_plugin_id
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
