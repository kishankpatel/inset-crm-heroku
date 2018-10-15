class ChangeTokenColumnInOfficeMails < ActiveRecord::Migration
  def up
    change_column :office_mails, :token, :text
  end

  def down
  	remove_column :office_mails, :token
  end
end
