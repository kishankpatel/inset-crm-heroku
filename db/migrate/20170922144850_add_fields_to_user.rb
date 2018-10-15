class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_setup_at, :datetime
    add_column :users, :smtp_config, :string
  end
end
