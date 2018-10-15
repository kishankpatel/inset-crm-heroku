class AddFieldsToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :is_won, :boolean
    add_column :deals, :lost_reason, :text
  end
end
