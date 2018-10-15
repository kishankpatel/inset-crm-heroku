class AddIsFunneLViewToDealStatus < ActiveRecord::Migration
  def change
    add_column :deal_statuses, :is_funnel_view, :boolean, default: true
  end
end
