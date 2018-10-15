class AddTotalAmountToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :total_amount, :string, default: 0
  end
end
