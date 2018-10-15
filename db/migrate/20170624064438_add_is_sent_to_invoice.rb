class AddIsSentToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :is_sent, :boolean, default: true
  end
end
