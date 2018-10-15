class AddOrganizationIdToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :organization_id, :integer
    Invoice.all.each do |invoice|
    	invoice.update_attributes(organization_id: invoice.user.organization.id)
    end
  end
end
