class AddQtyRateToInvoiceItem < ActiveRecord::Migration
  def change
    add_column :invoice_items, :qty, :integer
    add_column :invoice_items, :rate, :float
  end
end
