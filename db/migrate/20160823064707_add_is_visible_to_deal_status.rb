class AddIsVisibleToDealStatus < ActiveRecord::Migration
  def change
    add_column :deal_statuses, :is_visible, :boolean, default: true
  end
end
