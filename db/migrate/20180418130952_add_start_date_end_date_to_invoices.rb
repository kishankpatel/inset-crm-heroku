class AddStartDateEndDateToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :start_date, :date
    add_column :invoices, :end_date, :date
    add_column :invoices, :billable_hours, :integer
    add_column :invoices, :project_id, :integer
    add_index :invoices, :project_id
  end
end
