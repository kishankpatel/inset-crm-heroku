class AddDiscountToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :discount, :float
  end
end
