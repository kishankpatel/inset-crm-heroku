class AddFieldsToComment < ActiveRecord::Migration
  def change
    add_column :comments, :status, :string
    add_column :comments, :assigned_to, :integer
    add_column :comments, :priority, :string
    add_column :comments, :notify_email_ids, :string
  end
end
