class AddIsActivityDisplayToDealTransaction < ActiveRecord::Migration
  def change
    add_column :deal_transactions, :is_activity_display, :boolean, :default => true
  end
end
