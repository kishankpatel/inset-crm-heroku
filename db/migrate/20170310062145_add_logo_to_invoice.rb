class AddLogoToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :logo_url, :string
    add_column :invoices, :deal_id, :integer
    add_column :invoices, :company_name, :string
    add_column :invoices, :company_address, :text    
    add_column :invoices, :tax, :float
  end
end
