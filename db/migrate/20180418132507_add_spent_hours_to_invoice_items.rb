class AddSpentHoursToInvoiceItems < ActiveRecord::Migration
  def change

    add_column :invoice_items, :job_time_log_id, :integer
    add_index :invoice_items, :job_time_log_id
  end
end
