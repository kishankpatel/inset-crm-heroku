class RemoveMailLetterId < ActiveRecord::Migration
  def change
  	 remove_column :sent_email_opens, :mail_letter_id
  	 add_column :sent_email_opens, :activity_id, :integer
  end

end
