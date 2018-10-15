class AddColorToDealStatus < ActiveRecord::Migration
  def change
    add_column :deal_statuses, :color, :string
  end
end
