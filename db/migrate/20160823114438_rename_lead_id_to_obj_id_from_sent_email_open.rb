class RenameLeadIdToObjIdFromSentEmailOpen < ActiveRecord::Migration
  def change
  	rename_column :sent_email_opens, :lead_id, :obj_id
  end
end
