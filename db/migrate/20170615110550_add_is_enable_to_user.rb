class AddIsEnableToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_disabled, :boolean, :default => false
  end
end