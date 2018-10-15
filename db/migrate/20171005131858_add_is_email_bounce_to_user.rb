class AddIsEmailBounceToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_email_bounce, :boolean, :default => false
  end
end
