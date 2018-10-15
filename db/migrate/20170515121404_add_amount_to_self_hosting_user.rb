class AddAmountToSelfHostingUser < ActiveRecord::Migration
  def change
    add_column :self_hosting_users, :amount, :integer
  end
end
