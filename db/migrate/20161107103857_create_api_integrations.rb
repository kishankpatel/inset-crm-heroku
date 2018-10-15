class CreateApiIntegrations < ActiveRecord::Migration
  def change
    create_table :api_integrations do |t|
      t.integer :organization_id
      t.string  :url
      t.string  :api_name
      t.string  :account_id
      t.string  :auth_token
      t.string  :oauth_access_token
      t.timestamps
    end
  end
end
