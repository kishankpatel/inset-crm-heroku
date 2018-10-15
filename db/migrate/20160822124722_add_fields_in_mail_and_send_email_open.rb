class AddFieldsInMailAndSendEmailOpen < ActiveRecord::Migration
  def change
  	add_column :sent_emails, :obj_id, :integer
  	add_column :sent_emails, :obj_type, :string

  	add_column :sent_email_opens, :lead_id, :integer
  	add_column :sent_email_opens, :obj_type, :string
  	
  end
end
