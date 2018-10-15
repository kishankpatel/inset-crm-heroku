class AddInvoiceTypeToInvoices < ActiveRecord::Migration
  def up
    add_column :invoices, :invoice_type, :string, default: "invoice"
  end
  def down
    remove_column :invoices, :invoice_type
  end
end
