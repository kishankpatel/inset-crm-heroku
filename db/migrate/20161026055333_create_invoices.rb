class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :user_id
      t.integer :contact_id
      t.string :contact_type
      t.string :currency
      t.string :invoice_no
      t.date :due_date
      t.string :cc_mail_id
      t.string :status
      t.text :notes
      t.text :terms_and_condition
      t.date :transaction_date

      t.timestamps
    end
  end
end
