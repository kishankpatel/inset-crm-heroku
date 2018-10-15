class AddGmailRelatedIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :gmail_related_id, :integer
  end
end
