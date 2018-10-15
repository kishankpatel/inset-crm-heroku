class AddIsActiveToInvoices < ActiveRecord::Migration
  def up
    add_column :invoices, :is_active, :boolean, default: true
  end
  def down
    remove_column :invoices, :is_active
  end
end