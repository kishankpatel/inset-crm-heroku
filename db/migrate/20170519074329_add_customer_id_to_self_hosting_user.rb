class AddCustomerIdToSelfHostingUser < ActiveRecord::Migration
  def change
    add_column :self_hosting_users, :customer_id, :integer
    add_column :self_hosting_users, :total_users, :integer, :default => 0
  end
end
