class AddAssignedToToDealTransaction < ActiveRecord::Migration
  def change
    add_column :deal_transactions, :assigned_to, :integer
  end
end
